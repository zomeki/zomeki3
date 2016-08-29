module Cms::Nodes::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
  end

  def register_publisher
    register_node_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    name.present? && state == 'public' && !model.in?(%w(Cms::Page Cms::Directory Cms::SiteMap))
  end

  def register_node_publisher
    Cms::NodePublisher.register(id)
  end
end
