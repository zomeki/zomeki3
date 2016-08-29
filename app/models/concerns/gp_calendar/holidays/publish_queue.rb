module GpCalendar::Holidays::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
    before_destroy :register_publisher_callback
  end

  def register_publisher
    register_node_publisher
    register_piece_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    true
  end

  def register_node_publisher
    node_ids = content.nodes.public_state.pluck(:id)
    Cms::NodePublisher.register(node_ids)
  end

  def register_piece_publisher
    content.pieces.public_state.each do |piece|
      piece.register_publisher
    end
  end
end
