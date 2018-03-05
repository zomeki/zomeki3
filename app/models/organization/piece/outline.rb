class Organization::Piece::Outline < Cms::Piece
  default_scope { where(model: 'Organization::Outline') }

  belongs_to :content, class_name: 'Organization::Content::Group'
end
