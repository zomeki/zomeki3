class GpArticle::Piece::SearchDoc < Cms::Piece
  default_scope { where(model: 'GpArticle::SearchDoc') }

  after_initialize :set_default_settings

  def content
    GpArticle::Content::Doc.find(super.id)
  end

  def category_types_for_option
    content.category_types.map { |ct| ["#{ct.title}(#{ct.name})", ct.id] }
  end

  def category_types
    content.category_types.where(id: in_category_type_ids)
  end

  def in_category_type_ids
    YAML.load(in_settings['category_type_ids'].presence || '[]')
  end

  def in_category_type_ids=(value)
    category_type_ids = value.select(&:present?).map(&:to_i).uniq
    ins = in_settings
    ins['category_type_ids'] = YAML.dump(category_type_ids)
    self.in_settings = ins
  end

  private

  def set_default_settings
    settings = self.in_settings

    # settings['date_style'] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    # settings['docs_order'] = DOCS_ORDER_OPTIONS.first.last if setting_value(:docs_order).nil?
    # settings['impl'] = IMPL_OPTIONS.first.last if setting_value(:impl).blank?

    self.in_settings = settings
  end
end
