class Cms::PieceLinkItem < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Piece
  include Cms::Model::Auth::Concept

  enum_ish :state, [:public, :closed]
  enum_ish :target, ['', '_blank'], default: ''

  after_save     Cms::Publisher::PieceRelatedCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::PieceRelatedCallbacks.new, prepend: true

  validates :state, :name, :uri, presence: true

  def concept
    piece.concept
  end
  
  def creatable?
    editable?
  end
  
  def deletable?
    editable?
  end
end
