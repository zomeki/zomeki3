class GpArticle::Piece::SearchDoc < Cms::Piece
  default_scope { where(model: 'GpArticle::SearchDoc') }

  OPERATOR_OPTIONS = [['AND検索', 'and'], ['OR検索', 'or']]

  belongs_to :content, class_name: 'GpArticle::Content::Doc'

  after_initialize :set_default_settings

  def category_types_for_option
    content.category_types.map { |ct| ["#{ct.title}(#{ct.name})", ct.id] }
  end

  def category_types
    content.category_types.where(id: in_category_type_ids)
  end

  def in_category_type_ids
    YAML.load(in_settings['category_type_ids'].presence || '[]')
  end

  def operator_type
    setting_value(:operator_type)
  end

  def operator_type_text
    OPERATOR_OPTIONS.each{|so| return so.first if so.last == (in_settings[:operator_type] || setting_value(:operator_type)) }
    return nil
  end

  private

  def set_default_settings
    settings = self.in_settings
    settings['operator_type'] = 'or' if setting_value(:operator_type).nil?
    self.in_settings = settings
  end

end
