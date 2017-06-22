class GpArticle::Tool::DocsScript < Cms::Script::Base
  include Cms::Controller::Layout

  def rebuild
    content = GpArticle::Content::Doc.find(params[:content_id])
    return unless content

    doc_ids = content.public_docs.order(content.docs_order_as_hash).pluck(:id)
    doc_ids.each_slice(100) do |sliced_doc_ids|
      content.public_docs.where(id: sliced_doc_ids).each do |doc|
        ::Script.progress(doc) do
          doc.rebuild
        end
      end
    end

    Cms::NodesScript.new(target_node_id: content.public_nodes.pluck(:id)).publish if content.public_nodes.present?
  end
end
