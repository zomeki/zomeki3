module Concerns::Cms::Node::Queue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
    before_destroy :register_publisher_callback
  end

  def register_publisher
    register_node_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    return false unless Core.mode_system?
    return false if name.blank?
    return false if model.in?(%w(Cms::Page Cms::Directory Cms::SiteMap))
    true
  end

  def register_node_publisher
    Cms::NodePublisher.register(id)
  end
end
