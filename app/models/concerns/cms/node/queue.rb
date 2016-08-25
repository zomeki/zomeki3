module Concerns::Cms::Node::Queue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_after_save
  end

  def enqueue_publisher
    enqueue_node_publisher
  end

  private

  def enqueue_publisher_after_save
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    return false if name.blank?
    return false if model.in?(%w(Cms::Page Cms::Directory Cms::SiteMap))
    true
  end

  def enqueue_node_publisher
    Cms::NodePublisher.enqueue_node_ids(id)
    Cms::NodePublisher.delay(queue: 'publish_node_pages').publish_nodes
  end
end
