class GpArticle::Publisher::DocCallbacks < PublisherCallbacks
  def enqueue(doc)
    @doc = doc
    @content = doc.content
    @site = doc.site
    return unless enqueue?
    enqueue_pieces
    enqueue_nodes
    enqueue_organizations
    enqueue_categories
    enqueue_calendars
    enqueue_maps
    enqueue_tags
    enqueue_relatee_docs
    enqueue_sitemaps
  end

  private

  def enqueue?
    return unless super
    @doc.name.present? && @doc.state.in?(%w(public closed))
  end

  def enqueue_pieces
    pieces = @content.public_pieces.sort { |p| p.model == 'GpArticle::RecentTab' ? 1 : 9 }
    Cms::Publisher::PieceCallbacks.new.enqueue(pieces)
  end

  def enqueue_nodes
    extra_flag =
      if @content.simple_pagination?
        {}
      else
        column = @content.docs_order_columns.first
        changed_dates = [@doc.read_attribute(column)]
        changed_dates << @doc.prev_edition.read_attribute(column) if @doc.prev_edition
        changed_dates =
          if @content.monthly_pagination?
            changed_dates.compact.map(&:beginning_of_month)
          else
            changed_dates.compact.map(&:beginning_of_week)
          end
        { target_date: changed_dates.uniq.sort.map { |d| d.strftime('%Y-%m-%d') } }
      end
    Cms::Publisher.register(@site.id, @content.public_nodes, extra_flag)
  end

  def enqueue_organizations
    return unless organization_content = @content.organization_content_group
    return unless @doc.organization_group

    changed_ogs = [@doc.organization_group]
    changed_ogs << @doc.prev_edition.organization_group if @doc.prev_edition && @doc.prev_edition.organization_group
    changed_ogs.uniq!

    if changed_ogs.present?
      Cms::Publisher.register(@site.id, changed_ogs)
      Cms::Publisher::PieceCallbacks.new.enqueue(organization_content.public_pieces)
    end
  end

  def enqueue_categories
    category_content = @content.gp_category_content_category_type
    return unless category_content

    changed_cats = @doc.categories.flat_map(&:ancestors)
    changed_cats += @doc.prev_edition.categories.flat_map(&:ancestors) if @doc.prev_edition
    changed_cats.uniq!

    if changed_cats.present?
      Cms::Publisher.register(@site.id, changed_cats)
      Cms::Publisher::PieceCallbacks.new.enqueue(category_content.public_pieces_for_doc_list)
    end
  end

  def enqueue_calendars
    return unless @content.calendar_related?

    calendar_content = @content.gp_calendar_content_event
    return unless calendar_content

    changed_dates = [@doc.event_started_on, @doc.event_ended_on]
    changed_dates += [@doc.prev_edition.event_started_on, @doc.prev_edition.event_ended_on] if @doc.prev_edition
    changed_dates = changed_dates.uniq.compact

    if changed_dates.present?
      min_date = changed_dates.min.beginning_of_month
      max_date = changed_dates.max.beginning_of_month

      Cms::Publisher.register(@site.id, calendar_content.public_nodes,
                              target_min_date: min_date.strftime('%Y-%m-%d'),
                              target_max_date: max_date.strftime('%Y-%m-%d'))
      Cms::Publisher::PieceCallbacks.new.enqueue(calendar_content.public_pieces)
    end
  end

  def enqueue_maps
    return unless @content.map_related?

    map_content = @content.map_content_marker
    return unless map_content
    return unless @doc.maps[0]

    changed_markers = @doc.maps[0].markers.to_a
    changed_markers += @doc.prev_edition.maps[0].markers if @doc.prev_edition && @doc.prev_edition.maps[0]
    changed_markers.uniq!

    if changed_markers.present?
      Cms::Publisher.register(@site.id, map_content.public_nodes)
      Cms::Publisher::PieceCallbacks.new.enqueue(map_content.public_pieces)
    end
  end

  def enqueue_tags
    return unless @content.tag_related?

    tag_content = @content.tag_content_tag
    return unless tag_content

    changed_tags = @doc.tags.to_a
    changed_tags += @doc.prev_edition.tags if @doc.prev_edition
    changed_tags.uniq!

    if changed_tags.present?
      Cms::Publisher.register(@site.id, changed_tags)
      Cms::Publisher::PieceCallbacks.new.enqueue(tag_content.public_pieces)
    end
  end

  def enqueue_relatee_docs
    Cms::Publisher.register(@site.id, @doc.relatee_docs.where(state: 'public'))
  end

  def enqueue_sitemaps
    nodes = @site.nodes.where(model: 'Cms::SitemapXml')
    Cms::Publisher.register(@site.id, nodes)
   end
end
