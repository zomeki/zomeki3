module GpCategory::CategoryTypes::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :enqueue_publisher_callback, if: :changed?
    before_destroy :enqueue_publisher_callback
  end

  def enqueue_publisher
    enqueue_publisher_for_piece
    enqueue_publisher_for_category
    enqueue_publisher_for_doc
  end

  private

  def enqueue_publisher_callback
    enqueue_publisher if enqueue_publisher?
  end

  def enqueue_publisher?
    true
  end

  def enqueue_publisher_for_piece
    pieces = content.public_pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_category
    Cms::Publisher.register(content.site_id, public_categories.select(:id))
  end

  def enqueue_publisher_for_doc
    docs = public_categories.map {|c| c.docs.public_state.select(:id) }.flatten
    Cms::Publisher.register(content.site_id, docs.uniq)
  end
end
