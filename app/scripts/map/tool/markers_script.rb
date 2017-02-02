class Map::Tool::MarkersScript < Cms::Script::Base
  def rebuild
    content = Map::Content::Marker.find(params[:content_id])
    content.public_nodes.each do |node|
      script = node.script_model.constantize
      script.new(node_id: node.id).publish if script.publishable?
    end
  end
end
