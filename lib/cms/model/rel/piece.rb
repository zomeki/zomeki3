module Cms::Model::Rel::Piece
  extend ActiveSupport::Concern

  included do
    belongs_to :piece, class_name: 'Cms::Piece'
    delegate :site, to: :piece
    delegate :site_id, to: :piece
    nested_scope :in_site, through: :piece
  end
end
