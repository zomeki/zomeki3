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
  end

  private

  def enqueue?
    true
  end

  def enqueue_groups
    Cms::Publisher.register(@group.content.site_id, @group.public_ancestors)
  end
end
