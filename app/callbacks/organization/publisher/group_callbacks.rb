class Organization::Publisher::GroupCallbacks < PublisherCallbacks
  def enqueue(group)
    @group = group
    return unless enqueue?
    enqueue_pieces
    enqueue_groups
  end

  private

  def enqueue?
    return unless super
    [@group.state, @group.state_was].include?('public')
  end

  def enqueue_pieces
    Cms::Publisher::PieceCallbacks.new.enqueue(@group.content.public_pieces)
  end

  def enqueue_groups
    Cms::Publisher.register(@group.content.site_id, @group.public_ancestors)
  end
end
