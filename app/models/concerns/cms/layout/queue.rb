module Concerns::Cms::Layout::Queue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_after_save
  end

  def enqueue_publisher
    enqueue_node_publisher
    enqueue_category_publisher
    enqueue_organization_group_publisher
    enqueue_doc_publisher
  end

  private

  def enqueue_publisher_after_save
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    return false if name.blank?
    true
  end

  def enqueue_node_publisher
    node_ids = Cms::Node.where(layout_id: id).pluck(:id)
    if node_ids.present?
      Cms::NodePublisher.enqueue_node_ids(node_ids)
      Cms::NodePublisher.delay(queue: 'publish_node_pages').publish_nodes
    end
  end

  def enqueue_category_publisher
    cat_types = GpCategory::CategoryType.where(layout_id: id).all
    cat_types.each do |cat_type|
      cat_ids = cat_type.categories.pluck(:id)
      GpCategory::Publisher.enqueue_category_ids(cat_ids)
      GpCategory::Publisher.delay(queue: 'publish_category_pages').publish_categories
    end

    cat_ids = GpCategory::Category.where(layout_id: id).pluck(:id)
    if cat_ids.present?
      GpCategory::Publisher.enqueue_category_ids(cat_ids)
      GpCategory::Publisher.delay(queue: 'publish_category_pages').publish_categories
    end
  end

  def enqueue_organization_group_publisher
    group_codes = Organization::Group.where(layout_id: id).pluck(:sys_group_code)
    group_ids = Sys::Group.where(code: group_codes).pluck(:id)
    group_ids.each do |group_id|
      Organization::Publisher.enqueue_organization_group_ids(group_ids)
      Organization::Publisher.delay(queue: 'publish_organization_pages').publish_groups
    end
  end

  def enqueue_doc_publisher
    doc_ids = GpArticle::Doc.where(layout_id: id).pluck(:id)
    if doc_ids.present?
      GpArticle::Publisher.enqueue_doc_ids(doc_ids)
      GpArticle::Publisher.delay(queue: 'publish_article_pages').publish_docs
    end
  end
end
