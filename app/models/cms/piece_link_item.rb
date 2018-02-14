class Cms::PieceLinkItem < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Page
  include Cms::Model::Site
  include Cms::Model::Rel::Piece
  include Cms::Model::Auth::Concept

  enum_ish :state, [:public, :closed]
  enum_ish :target, ['', '_blank'], default: ''

  after_save     Cms::Publisher::PieceRelatedCallbacks.new, if: :changed?
  before_destroy Cms::Publisher::PieceRelatedCallbacks.new

  validates :state, :name, :uri, presence: true

  def concept(flag = nil)
    piece.concept(flag)
  end
  
  def creatable?
    editable?
  end
  
  def deletable?
    editable?
  end
end
