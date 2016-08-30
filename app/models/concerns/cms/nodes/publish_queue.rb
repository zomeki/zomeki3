module Cms::Nodes::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
  end

  def enqueue_publisher
    enqueue_publisher_for_node
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    name.present? && state == 'public' && !model.in?(%w(Cms::Page Cms::Directory Cms::SiteMap))
  end

  def enqueue_publisher_for_node
    Cms::Publisher.register(self)
  end
end
