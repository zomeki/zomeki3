module GpCategory::Categories::PublishQueue
  extend ActiveSupport::Concern

  included do
    after_save :register_publisher_callback, if: :changed?
    before_destroy :register_publisher_callback
  end

  def register_publisher
    register_category_publisher
    register_piece_publisher
    register_doc_publisher
  end

  private

  def register_publisher_callback
    register_publisher if register_publisher?
  end

  def register_publisher?
    return false unless Core.mode_system?
    true
  end

  def register_category_publisher
    GpCategory::Publisher.register(id)
  end

  def register_piece_publisher
    Cms::Piece.where(content_id: id).each do |piece|
      piece.register_publisher
    end
  end

  def register_doc_publisher
    GpArticle::Publisher.register(docs.map(&:id))
  end
end
