module Cms::Base::PublishQueue::Content::Content
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
    before_destroy :enqueue_publisher_callback
  end

  def enqueue_publisher
    Cms::Publisher.register(content.site_id, content.public_nodes.select(:id))
    content.public_pieces.each do |piece|
      piece.enqueue_publisher
    end
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    true
  end
end
