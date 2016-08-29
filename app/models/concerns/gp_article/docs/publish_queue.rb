module GpArticle::Docs::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
    before_destroy :enqueue_publisher_callback
  end

  def enqueue_publisher
    enqueue_publisher_for_piece
    enqueue_publisher_for_node
    enqueue_publisher_for_organization
    enqueue_publisher_for_category
    enqueue_publisher_for_calendar
    enqueue_publisher_for_map
    enqueue_publisher_for_tag
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    name.present? && state.in?(%w(public closed))
  end

  def enqueue_publisher_for_piece
    pieces = content.pieces.public_state
    pieces = pieces.sort { |p| p.model == 'GpArticle::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_node
    node_ids = content.nodes.public_state.pluck(:id)
    Cms::NodePublisher.register(node_ids)
  end

  def enqueue_publisher_for_organization
    return unless organization_content = content.organization_content_group
    return unless organization_group

    og_ids = [organization_group.id]
    og_ids << prev_edition.organization_group.id if prev_edition && prev_edition.organization_group
    Organization::Publisher.register(og_ids.uniq)

    organization_content.pieces.public_state.each do |piece|
      piece.enqueue_publisher
    end 
  end

  def enqueue_publisher_for_category
    category_content = content.gp_category_content_category_type
    return unless category_content

    cat_ids = categories.map {|c| c.ancestors.map(&:id) }.flatten
    cat_ids += prev_edition.categories.map {|c| c.ancestors.map(&:id) }.flatten if prev_edition
    GpCategory::Publisher.register(cat_ids.uniq)

    category_content.pieces.public_state.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_calendar
    return unless content.calendar_related?

    calendar_content = content.gp_calendar_content_event
    return unless calendar_content

    node_ids = calendar_content.nodes.public_state.pluck(:id)
    Cms::NodePublisher.register(node_ids)

    calendar_content.pieces.public_state.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_map
    return unless content.map_related?

    map_content = content.map_content_marker
    return unless map_content

    node_ids = map_content.nodes.public_state.pluck(:id)
    Cms::NodePublisher.register(node_ids)

    map_content.pieces.public_state.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_tag
    return unless content.tag_related?

    tag_content = content.tag_content_tag
    return unless tag_content

    node_ids = tag_content.nodes.public_state.pluck(:id)
    Cms::NodePublisher.register(node_ids)

    tag_content.pieces.public_state.each do |piece|
      piece.enqueue_publisher
    end
  end
end
