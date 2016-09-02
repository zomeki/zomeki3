module Map::Markers::PublishQueue
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

  def enqueue_publisher_for_piece
    content.public_pieces.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_node
    Cms::Publisher.register(content.site_id, content.public_nodes.select(:id))
  end
end
