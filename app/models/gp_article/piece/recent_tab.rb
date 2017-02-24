class GpArticle::Piece::RecentTab < Cms::Piece
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'published_at_desc'], ['公開日（昇順）', 'published_at_asc'],
                        ['更新日（降順）', 'updated_at_desc'], ['更新日（昇順）', 'updated_at_asc'],
                        ['ランダム', 'random']]

  default_scope { where(model: 'GpArticle::RecentTab') }

  after_initialize :set_default_settings

  validate :validate_settings

  def validate_settings
    if (lc = in_settings['list_count']).present?
      errors.add(:base, "#{self.class.human_attribute_name :list_count} #{errors.generate_message(:base, :not_a_number)}") unless lc =~ /^[0-9]+$/
    end
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def docs_order_as_sql
    map = {
      'published_at_desc' => { display_published_at: :desc, published_at: :desc },
      'published_at_asc' => { display_published_at: :asc, published_at: :asc },
      'updated_at_desc' => { display_updated_at: :desc, updated_at: :desc },
      'updated_at_asc' => { display_updated_at: :asc, updated_at: :asc },
      'random' => 'RANDOM()'
    }
    map[docs_order] || map['published_at_desc']
  end

  def list_count
    (setting_value(:list_count).presence || 10).to_i
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def more_label
    setting_value(:more_label).to_s
  end

  def content
    GpArticle::Content::Doc.find(super.id)
  end

  def category_types
    content.category_types
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
  end

  private

  def set_default_settings
    settings = self.in_settings
    settings[:list_count] = 10 if setting_value(:list_count).nil?
    settings[:list_style] = '@title_link@(@publish_date@ @group@)' if setting_value(:list_style).nil?
    settings[:date_style] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    settings[:more_label] = '' if setting_value(:list_count).nil?
    self.in_settings = settings
  end
end
