class Cms::Piece::Link < Cms::Piece
  has_many :link_items, -> { order(:sort_no) }, :foreign_key => :piece_id,
    :class_name => 'Cms::PieceLinkItem', :dependent => :destroy
end
