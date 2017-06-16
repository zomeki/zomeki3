class Organization::Publisher::GroupCallbacks < PublisherCallbacks
  def enqueue(group)
    @group = group
    return unless enqueue?
    enqueue_groups
    enqueue_sitemap_nodes
  end

  private

  def enqueue?
    return unless super
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
