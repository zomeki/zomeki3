class Organization::Piece::BusinessOutline < Cms::Piece
  default_scope { where(model: 'Organization::BusinessOutline') }

  belongs_to :content, class_name: 'Organization::Content::Group'
end
