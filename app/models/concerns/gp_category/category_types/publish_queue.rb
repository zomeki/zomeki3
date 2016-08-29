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
    pieces = content.pieces.public_state
    pieces = pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      piece.enqueue_publisher
    end
  end

  def enqueue_publisher_for_category
    GpCategory::Publisher.register(public_categories.pluck(:id))
  end

  def enqueue_publisher_for_doc
    doc_ids = public_categories.map {|c| c.docs.public_state.pluck(:id) }.flatten
    GpArticle::Publisher.register(doc_ids.uniq)
  end
end
