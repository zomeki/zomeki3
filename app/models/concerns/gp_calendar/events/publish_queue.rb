module GpCalendar::Events::PublishQueue
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
    return false unless Core.mode_system?
    return false unless state.in?(%w(public closed))
    true
  end

  def register_node_publisher
    node_ids = Cms::Node.where(content_id: content_id).pluck(:id)
    Cms::NodePublisher.register(node_ids)
  end

  def register_piece_publisher
    Cms::Piece.where(content_id: content_id).each do |piece|
      piece.register_publisher
    end
  end
end
