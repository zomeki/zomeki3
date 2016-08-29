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
    node_ids = Cms::Node.public_state.where(layout_id: id).pluck(:id)
    Cms::NodePublisher.register(node_ids)
  end

  def enqueue_publisher_for_category
    cat_types = GpCategory::CategoryType.public_state.where(layout_id: id).all
    cat_types.each do |cat_type|
      cat_ids = cat_type.categories.pluck(:id)
      GpCategory::Publisher.register(cat_ids)
    end

    cat_ids = GpCategory::Category.public_state.where(layout_id: id).pluck(:id)
    GpCategory::Publisher.register(cat_ids)
  end

  def enqueue_publisher_for_organization_group
    og_ids = Organization::Group.public_state.with_layout(id).pluck(:id)
    Organization::Publisher.register(og_ids)
  end

  def enqueue_publisher_for_doc
    doc_ids = GpArticle::Doc.public_state.where(layout_id: id).pluck(:id)
    GpArticle::Publisher.register(doc_ids)
  end
end
