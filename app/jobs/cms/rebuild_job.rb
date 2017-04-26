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
    ::Script.run("cms/tool/contents/rebuild", site_id: site_id, content_id: target_content_ids)
  end

  def perform_nodes(site_id, target_node_ids)
    ::Script.run("cms/tool/pages/rebuild", site_id: site_id, node_id: target_node_ids)
  end
end
