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
    name.present? && state.in?(%w(public finish))
  end

  def enqueue_publisher_for_piece
    pieces = content.public_pieces
    pieces = pieces.sort { |p| p.model == 'GpArticle::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_node
    Cms::Publisher.register(content.site_id, content.public_nodes.select(:id),
        target_date: display_published_at || published_at
      )
  end

  def enqueue_publisher_for_organization
    return unless organization_content = content.organization_content_group
    return unless organization_group

    changed_ogs = [organization_group]
    changed_ogs << prev_edition.organization_group if prev_edition && prev_edition.organization_group
    changed_ogs.uniq!

    if changed_ogs.present?
      Cms::Publisher.register(content.site_id, changed_ogs)
      organization_content.public_pieces.each do |piece|
        piece.enqueue_publisher
      end
    end
  end

  def enqueue_publisher_for_category
    category_content = content.gp_category_content_category_type
    return unless category_content

    changed_cats = categories.map {|c| c.ancestors }.flatten
    changed_cats += prev_edition.categories.map {|c| c.ancestors }.flatten if prev_edition
    changed_cats.uniq!

    if changed_cats.present?
      Cms::Publisher.register(content.site_id, changed_cats)
      category_content.public_pieces.each do |piece|
        piece.enqueue_publisher
      end
    end
  end

  def enqueue_publisher_for_calendar
    return unless content.calendar_related?

    calendar_content = content.gp_calendar_content_event
    return unless calendar_content

    changed_dates = [event_started_on, event_ended_on]
    changed_dates += [prev_edition.event_started_on, prev_edition.event_ended_on] if prev_edition
    changed_dates.uniq!.compact!

    if changed_dates.present?
      min_date = changed_dates.min.beginning_of_month
      max_date = changed_dates.max.beginning_of_month

      Cms::Publisher.register(content.site_id, calendar_content.public_nodes.select(:id),
        target_min_date: min_date.strftime('%Y-%m-%d'),
        target_max_date: max_date.strftime('%Y-%m-%d')
      )
      calendar_content.public_pieces.each do |piece|
        piece.enqueue_publisher
      end
    end
  end

  def enqueue_publisher_for_map
    return unless content.map_related?

    map_content = content.map_content_marker
    return unless map_content
    return unless maps[0]

    changed_markers = maps[0].markers.to_a
    changed_markers += prev_edition.maps[0].markers if prev_edition && prev_edition.maps[0]
    changed_markers.uniq!

    if changed_markers.present?
      Cms::Publisher.register(content.site_id, map_content.public_nodes.select(:id))
      map_content.public_pieces.each do |piece|
        piece.enqueue_publisher
      end
    end
  end

  def enqueue_publisher_for_tag
    return unless content.tag_related?

    tag_content = content.tag_content_tag
    return unless tag_content

    changed_tags = tags.to_a
    changed_tags += prev_edition.tags if prev_edition
    changed_tags.uniq!

    if changed_tags.present?
      Cms::Publisher.register(content.site_id, changed_tags)
      tag_content.public_pieces.each do |piece|
        piece.enqueue_publisher
      end
    end
  end
end
