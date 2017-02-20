class Cms::RebuildJob < ApplicationJob
  queue_as :cms_rebuild
  queue_with_priority 20

  def perform(options)
    if options[:target_content_ids]
      perform_contents(options[:site_id], options[:target_content_ids])
    elsif options[:target_node_ids]
      perform_nodes(options[:site_id], options[:target_node_ids])
    end
  end

  private

  def perform_contents(site_id, target_content_ids)
    contents = Cms::Content.where(id: target_content_ids)
    contents.each do |content|
      script_name = content.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/tool/')
      ::Script.run("#{script_name}/rebuild", site_id: site_id, content_id: content.id)
    end
  end

  def perform_nodes(site_id, target_node_ids)
    ::Script.run("cms/tool/pages/rebuild", site_id: site_id, node_id: target_node_ids)
  end
end
