module Cms::Layouts::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
    before_destroy :enqueue_publisher_callback
  end

  def enqueue_publisher
    enqueue_publisher_for_node
    enqueue_publisher_for_category
    enqueue_publisher_for_organization_group
    enqueue_publisher_for_doc
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    name.present?
  end

  def enqueue_publisher_for_node
    nodes = Cms::Node.public_state.where(layout_id: id).select(:id, :parent_id, :name)
    Cms::Publisher.register(site_id, nodes)
  end

  def enqueue_publisher_for_category
    cat_types = GpCategory::CategoryType.public_state.where(layout_id: id).all
    cat_types.each do |cat_type|
      Cms::Publisher.register(site_id, cat_type.public_categories.select(:id))
    end

    cats = GpCategory::Category.public_state.where(layout_id: id).select(:id)
    Cms::Publisher.register(site_id, cats)
  end

  def enqueue_publisher_for_organization_group
    ogs = Organization::Group.public_state.with_layout(id).select(:id)
    Cms::Publisher.register(site_id, ogs)
  end

  def enqueue_publisher_for_doc
    docs = GpArticle::Doc.public_state.where(layout_id: id).select(:id)
    Cms::Publisher.register(site_id, docs)
  end
end
