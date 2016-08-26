module Concerns::Cms::Layout::Queue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
    before_destroy :register_publisher_callback
  end

  def register_publisher
    register_node_publisher
    register_category_publisher
    register_organization_group_publisher
    register_doc_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    return false unless Core.mode_system?
    return false if name.blank?
    true
  end

  def register_node_publisher
    node_ids = Cms::Node.where(layout_id: id).pluck(:id)
    Cms::NodePublisher.register(node_ids)
  end

  def register_category_publisher
    cat_types = GpCategory::CategoryType.where(layout_id: id).all
    cat_types.each do |cat_type|
      cat_ids = cat_type.categories.pluck(:id)
      GpCategory::Publisher.register(cat_ids)
    end

    cat_ids = GpCategory::Category.where(layout_id: id).pluck(:id)
    GpCategory::Publisher.register(cat_ids)
  end

  def register_organization_group_publisher
    group_ids = Organization::Group.where(layout_id: id).pluck(:id)
    Organization::Publisher.register(group_ids)
  end

  def register_doc_publisher
    doc_ids = GpArticle::Doc.where(layout_id: id).pluck(:id)
    GpArticle::Publisher.register(doc_ids)
  end
end
