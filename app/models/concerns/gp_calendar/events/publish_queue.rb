module GpCalendar::Events::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
    before_destroy :enqueue_publisher_callback
  end

  def enqueue_publisher
    enqueue_publisher_for_node
    enqueue_publisher_for_piece
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    true
  end

  def enqueue_publisher_for_node
    node_ids = content.nodes.public_state.pluck(:id)
    Cms::NodePublisher.register(node_ids)
  end

  def enqueue_publisher_for_piece
    content.pieces.public_state.each do |piece|
      piece.enqueue_publisher
    end
  end
end
