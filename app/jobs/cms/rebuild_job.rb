class Cms::RebuildJob < ApplicationJob
  queue_as :cms_rebuild
  queue_with_priority 20

  def perform(site, options)
    @site = site

    if options[:all]
      options[:target_content_ids] = load_all_content_ids
      options[:target_node_ids] = load_all_node_ids
    end

    if options[:target_content_ids].present?
      perform_contents(options[:target_content_ids])
    end
    if options[:target_node_ids].present?
      perform_nodes(options[:target_node_ids])
    end
    
    if options[:target_doc_ids].present?
      perform_docs(options[:target_doc_ids])
    end
  end

  private

  def load_all_content_ids
    @site.contents.rebuildable_models.joins(:nodes)
         .where(Cms::Node.arel_table[:state].eq('public'))
         .pluck(:id).uniq
  end

  def load_all_node_ids
    @site.nodes.rebuildable_models.public_state.pluck(:id)
  end

  def perform_contents(target_content_ids)
    ::Script.run("cms/tool/contents/rebuild", site_id: @site.id, content_id: target_content_ids)
  end

  def perform_nodes(target_node_ids)
    ::Script.run("cms/tool/pages/rebuild", site_id: @site.id, node_id: target_node_ids)
  end

  def perform_docs(target_doc_ids)
    ::Script.run("gp_article/tool/docs/rebuild", site_id: @site.id, doc_id:target_doc_ids)
  end
end
