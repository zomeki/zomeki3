class GpCategory::Piece::CategorySummary < Cms::Piece


  default_scope { where(model: 'GpCategory::CategorySummary') }

  def content
    GpCategory::Content::CategoryType.find(super.id)
  end

end
