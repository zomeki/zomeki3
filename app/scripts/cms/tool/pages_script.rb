class Cms::Tool::PagesScript < Cms::Script::Base
  include Cms::Controller::Layout

  def rebuild
    nodes = Cms::Node.where(id: params[:node_id])

    ::Script.total nodes.size

    nodes.each do |node|
      ::Script.progress(node) do
        page = Cms::Node::Page.find(node.id)
        if page.rebuild(render_public_as_string(page.public_uri, site: node.site))
          page.publish_page(render_public_as_string("#{page.public_uri}.r", site: node.site), path: "#{page.public_path}.r", dependent: :ruby)
          page.rebuild(render_public_as_string(page.public_uri, site: node.site, agent_type: :smart_phone),
                       path: page.public_smart_phone_path, dependent: :smart_phone)
        end
      end
    end
  end
end
