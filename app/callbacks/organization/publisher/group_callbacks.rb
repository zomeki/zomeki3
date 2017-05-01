class Organization::Publisher::GroupCallbacks < PublisherCallbacks
  def after_save(group)
    @group = group
    enqueue if enqueue?
  end

  def before_destroy(group)
    @group = group
    enqueue if enqueue?
  end

  def enqueue(group = nil)
    @group = group if group
    enqueue_groups
    enqueue_sitemap_nodes
  end

  private

  def enqueue?
    [@group.state, @group.state_was].include?('public')
  end

  def enqueue_groups
    Cms::Publisher.register(@group.content.site_id, @group.public_ancestors)
  end

  def enqueue_sitemap_nodes
    if [@group.sitemap_state, @group.sitemap_state_was].include?('visible')
      site = @group.content.site
      Cms::Publisher.register(site.id, site.public_sitemap_nodes)
    end
  end
end
