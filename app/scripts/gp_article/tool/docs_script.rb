class GpArticle::Tool::DocsScript < ParametersScript
  def rebuild
    if params[:doc_id]
      doc_ids = GpArticle::Doc.public_state.where(id: params[:doc_id]).pluck(:id)
      rebuild_doc(doc_ids)
    else
      content = GpArticle::Content::Doc.find(params[:content_id])
      return unless content
      return unless content.public_node
  
      doc_ids = content.docs.public_state.order(content.docs_order_as_hash).pluck(:id)
      rebuild_doc(doc_ids)
      Cms::NodesScript.new(target_node_id: content.public_nodes.pluck(:id)).publish if content.public_nodes.present?
    end
  end
  
  private
  
  def rebuild_doc(doc_ids)
    doc_ids.each_slice(100) do |sliced_doc_ids|
      GpArticle::Doc.public_state.where(id: sliced_doc_ids).each do |doc|
        ::Script.progress(doc) do
          doc.rebuild
        end
      end
    end
  end
  
end
