class GpArticle::DocsScript < PublicationScript
  def publish
    docs = @node.content.docs.public_state.where(id: params[:target_doc_id])
    docs.find_each do |doc|
      ::Script.progress(doc) do
        doc.rebuild
      end
    end

    Cms::FileTransferCallbacks.new([:public_path, :public_smart_phone_path], recursive: true).after_publish_files(@node)
  end
end
