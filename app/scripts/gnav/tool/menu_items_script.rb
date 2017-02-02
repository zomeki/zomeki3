class Gnav::Tool::MenuItemsScript < Cms::Script::Base
  def rebuild
    content = Gnav::Content::MenuItem.find(params[:content_id])
    content.public_nodes.each do |node|
      script = node.script_model.constantize
      script.new(node_id: node.id).publish if script.publishable?
    end
  end
end
