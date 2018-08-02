class Cms::Tool::ContentsScript < ParametersScript
  def rebuild
    Array(params[:content_id]).each do |content_id|
      content = Cms::Content.find_by(id: content_id)
      next unless content

      if (script_klass = "#{content.model.pluralize.sub('::', '::Tool::')}Script".safe_constantize)
        script_klass.new(content_id: content.id).rebuild
      else
        Cms::NodesScript.new(target_node_id: content.public_nodes.pluck(:id)).publish if content.public_nodes.present?
      end
    end
  end
end
