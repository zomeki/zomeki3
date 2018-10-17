class Cms::Tool::ContentsScript < ParametersScript
  def rebuild
    Array(params[:content_id]).each do |content_id|
      content = Cms::Content.find_by(id: content_id)
      next unless content

      if (script_klass = "#{content.model.pluralize.sub('::', '::Tool::')}Script".safe_constantize)
        script_klass.new(content_id: content.id).rebuild
      else
        if (nodes = content.public_nodes).present?
          Cms::NodesScript.new(target_node_id: nodes.pluck(:id)).publish
        end
        if (pieces = content.public_pieces).present?
          Cms::PiecesScript.new(target_piece_id: pieces.pluck(:id)).publish
        end
      end
    end
  end
end
