class Cms::Tool::ContentsScript < Cms::Script::Base
  def rebuild
    Array(params[:content_id]).each do |content_id|
      content = Cms::Content.find_by(id: content_id)
      next unless content

      script_name = content.model.underscore.gsub(/^(.*?)\//, '\1/tool/')
      if (script_klass = "#{script_name.classify.pluralize}Script".safe_constantize)
        script_klass.new(content_id: content.id).rebuild
      else
        Cms::NodesScript.new(target_node_id: content.public_nodes.pluck(:id)).publish if content.public_nodes.present?
      end
    end
  end
end
