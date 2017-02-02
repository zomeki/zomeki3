class GpArticle::Tool::DocsScript < Cms::Script::Base
  include Cms::Controller::Layout

  def rebuild
    content = GpArticle::Content::Doc.find(params[:content_id])

    doc_ids = content.public_docs.order(display_published_at: :desc, published_at: :desc).pluck(:id)
    doc_ids.each_slice(100) do |sliced_doc_ids|
      content.public_docs.where(id: sliced_doc_ids).each do |doc|
        ::Script.progress do
          if doc.rebuild(render_public_as_string("#{doc.public_uri}index.html", site: content.site))
            doc.publish_page(render_public_as_string("#{doc.public_uri}index.html.r", site: content.site),
                             path: "#{doc.public_path}.r", dependent: :ruby)
            doc.rebuild(render_public_as_string("#{doc.public_uri}index.html", site: content.site, agent_type: :smart_phone),
                        path: doc.public_smart_phone_path, dependent: :smart_phone)
          end
        end
      end
    end

    content.public_nodes.each do |node|
      script = node.script_model.constantize
      script.new(node_id: node.id).publish if script.publishable?
    end
  end
end
