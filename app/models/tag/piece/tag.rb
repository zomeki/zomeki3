class Tag::Piece::Tag < Cms::Piece
  default_scope { where(model: 'Tag::Tag') }

  belongs_to :content, class_name: 'Tag::Content::Tag'
end
