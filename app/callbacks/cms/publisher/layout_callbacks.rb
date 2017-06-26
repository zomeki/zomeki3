class Cms::Publisher::LayoutCallbacks < PublisherCallbacks
  def enqueue(layouts)
    @layouts = layouts
    return unless enqueue?

    @site = @layouts.first.site
    enqueue_nodes
    enqueue_categories
    enqueue_organization_groups
    enqueue_gnav_menu_items
    enqueue_docs
  end

  private

  def enqueue?
    return unless super
    @layouts = Array(@layouts).select { |layout| layout.name.present? }
    @layouts.present?
  end

  def enqueue_nodes
    nodes = Cms::Node.public_state.where(layout_id: @layouts.map(&:id))
    Cms::Publisher.register(@site.id, nodes)
  end

  def enqueue_categories
    cats = GpCategory::CategoryType.public_state.where(layout_id: @layouts.map(&:id))
                                   .flat_map { |cat_type| cat_type.public_categories }
    cats += GpCategory::Category.public_state.where(layout_id: @layouts.map(&:id))
    Cms::Publisher.register(@site.id, cats.uniq)
  end

  def enqueue_organization_groups
    ogs = Organization::Group.public_state.with_layout(@layouts.map(&:id))
    Cms::Publisher.register(@site.id, ogs)
  end

  def enqueue_gnav_menu_items
    contents = Gnav::Content::MenuItem.where(id: Gnav::MenuItem.select(:content_id).where(state: 'public', layout_id: @layouts.map(&:id)))
    nodes = Cms::Node.public_state.where(content_id: contents)
    Cms::Publisher.register(@site.id, nodes)
  end

  def enqueue_docs
    docs = GpArticle::Doc.public_state.where(layout_id: @layouts.map(&:id)).select(:id)
    Cms::Publisher.register(@site.id, docs)
  end
end
