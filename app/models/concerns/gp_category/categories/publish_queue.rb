module GpCategory::Categories::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
    before_destroy :register_publisher_callback
  end

  def register_publisher
    register_piece_publisher
    register_category_publisher
    register_doc_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    true
  end

  def register_piece_publisher
    pieces = content.pieces.public_state
    pieces = pieces.sort { |p| p.model == 'GpCategory::RecentTab' ? 1 : 9 }
    pieces.each do |piece|
      piece.register_publisher
    end
  end

  def register_category_publisher
    GpCategory::Publisher.register(ancestors.map(&:id))
  end

  def register_doc_publisher
    doc_ids = public_descendants.map {|c| c.docs.public_state.pluck(:id) }.flatten
    GpArticle::Publisher.register(doc_ids.uniq)
  end
end
