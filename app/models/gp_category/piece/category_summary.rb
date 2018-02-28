class GpCategory::Piece::CategorySummary < Cms::Piece
  default_scope { where(model: 'GpCategory::CategorySummary') }

  belongs_to :content, class_name: 'GpCategory::Content::CategoryType'
end
