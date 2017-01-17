class GpArticle::Piece::SearchDoc < Cms::Piece
  default_scope { where(model: 'GpArticle::SearchDoc') }

  after_initialize :set_default_settings

  private

  def set_default_settings
    settings = self.in_settings

    # settings['date_style'] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    # settings['docs_order'] = DOCS_ORDER_OPTIONS.first.last if setting_value(:docs_order).nil?
    # settings['impl'] = IMPL_OPTIONS.first.last if setting_value(:impl).blank?

    self.in_settings = settings
  end
end
