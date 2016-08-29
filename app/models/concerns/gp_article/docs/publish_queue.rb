module GpArticle::Docs::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
    before_destroy :register_publisher_callback
  end

  def register_publisher
    register_piece_publisher
    register_node_publisher
    register_organization_publisher
    register_category_publisher
    register_calendar_publisher
    register_map_publisher
    register_tag_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    name.present? && state.in?(%w(public closed))
  end

  def register_piece_publisher
    pieces = content.pieces.public_state
    pieces = pieces.sort { |p| p.model == 'GpArticle::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      piece.register_publisher
    end
  end

  def register_node_publisher
    node_ids = content.nodes.public_state.pluck(:id)
    Cms::NodePublisher.register(node_ids)
  end

  def register_organization_publisher
    return unless organization_content = content.organization_content_group
    return unless organization_group

    og_ids = [organization_group.id]
    og_ids << prev_edition.organization_group.id if prev_edition && prev_edition.organization_group
    Organization::Publisher.register(og_ids.uniq)

    Cms::Piece.where(content_id: organization_content.id).each do |piece|
      piece.register_publisher
    end 
  end

  def register_category_publisher
    category_content = content.gp_category_content_category_type
    return unless category_content

    cat_ids = categories.map {|c| c.ancestors.map(&:id) }.flatten
    cat_ids += prev_edition.categories.map {|c| c.ancestors.map(&:id) }.flatten if prev_edition
    GpCategory::Publisher.register(cat_ids.uniq)

    Cms::Piece.where(content_id: category_content.id).each do |piece|
      piece.register_publisher
    end
  end

  def register_calendar_publisher
    return unless content.calendar_related?

    calendar_content = content.gp_calendar_content_event
    return unless calendar_content

    node_ids = Cms::Node.where(content_id: calendar_content.id).pluck(:id)
    Cms::NodePublisher.register(node_ids)

    Cms::Piece.where(content_id: calendar_content.id).each do |piece|
      piece.register_publisher
    end
  end

  def register_map_publisher
    return unless content.map_related?

    map_content = content.map_content_marker
    return unless map_content

    node_ids = Cms::Node.where(content_id: map_content.id).pluck(:id)
    Cms::NodePublisher.register(node_ids)

    Cms::Piece.where(content_id: map_content.id).each do |piece|
      piece.register_publisher
    end
  end

  def register_tag_publisher
    return unless content.tag_related?

    tag_content = content.tag_content_tag
    return unless tag_content

    node_ids = Cms::Node.where(content_id: tag_content.id).pluck(:id)
    Cms::NodePublisher.register(node_ids)

    Cms::Piece.where(content_id: tag_content.id).each do |piece|
      piece.register_publisher
    end
  end
end
