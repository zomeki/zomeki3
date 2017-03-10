class Cms::Publisher::LayoutCallbacks < PublisherCallbacks
  def after_save(layout)
    @layout = layout
    enqueue if enqueue?
  end

  def before_destroy(layout)
    @layout = layout
    enqueue if enqueue?
  end

  def enqueue(layout = nil)
    @layout = layout if layout
    enqueue_nodes
    enqueue_categories
    enqueue_organization_groups
    enqueue_docs
  end

  private

  def enqueue?
    @layout.name.present?
  end

  def enqueue_nodes
    nodes = Cms::Node.public_state.where(layout_id: @layout.id).select(:id, :parent_id, :name)
    Cms::Publisher.register(@layout.site_id, nodes)
  end

  def enqueue_categories
    cat_types = GpCategory::CategoryType.public_state.where(layout_id: @layout.id).all
    cat_types.each do |cat_type|
      Cms::Publisher.register(@layout.site_id, cat_type.public_categories.select(:id))
    end

    cats = GpCategory::Category.public_state.where(layout_id: @layout.id).select(:id)
    Cms::Publisher.register(@layout.site_id, cats)
  end

  def enqueue_organization_groups
    ogs = Organization::Group.public_state.with_layout(@layout.id).select(:id)
    Cms::Publisher.register(@layout.site_id, ogs)
  end

  def enqueue_docs
    docs = GpArticle::Doc.public_state.where(layout_id: @layout.id).select(:id)
    Cms::Publisher.register(@layout.site_id, docs)
  end
end
