module Cms::Model::Rel::Piece
  extend ActiveSupport::Concern

  included do
    belongs_to :piece, class_name: 'Cms::Piece'
    delegate :site, to: :piece
    delegate :site_id, to: :piece
    scope :in_site, ->(site) { where(piece_id: Cms::Piece.where(site_id: site)) }
  end
end
