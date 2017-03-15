class Reception::Piece::Course < Cms::Piece
  DOCS_FILTER_OPTIONS = [['公開中全て', 'public'], ['申し込み期間', 'available']]
  DOCS_ORDER_OPTIONS = [['登録順（降順）', 'id_desc'], ['登録順（昇順）', 'id_asc'],
                        ['開催日順（降順）', 'open_at_desc'], ['開催日順（昇順）', 'open_at_asc']]
  LAYER_OPTIONS = [['下層のカテゴリすべて', 'descendants'], ['該当カテゴリのみ', 'self']]

  default_scope { where(model: 'Reception::Course') }

  after_initialize :set_default_settings

  validate :validate_docs_number

  def docs_filter
    setting_value(:docs_filter).to_s
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def docs_number
    (setting_value(:docs_number).presence || 1000).to_i
  end

  def more_link_body
    setting_value(:more_link_body).to_s
  end

  def more_link_url
    setting_value(:more_link_url).to_s
  end

  def category_sets
    value = YAML.load(setting_value(:category_sets).to_s)
    return [] unless value.is_a?(Array)
    value.map {|v|
      next nil if (v[:category_type] = GpCategory::CategoryType.find_by(id: v[:category_type_id])).nil?
      next nil if v[:category_id].nonzero? && (v[:category] = GpCategory::Category.find_by(id: v[:category_id])).nil?
      next v
    }.compact.sort do |a, b|
      next a[:category_type].unique_sort_key <=> b[:category_type].unique_sort_key if a[:category].nil? && b[:category].nil?
      next a[:category_type].unique_sort_key <=> b[:category].unique_sort_key if a[:category].nil?
      next a[:category].unique_sort_key <=> b[:category_type].unique_sort_key if b[:category].nil?
      a[:category].unique_sort_key <=> b[:category].unique_sort_key
    end
  end

  def new_category_set
    { category_type_id: nil, category_id: nil, layer: LAYER_OPTIONS.first.last }
  end

  def public_categories
    category_sets.map { |cs|
      if cs[:category_type] && !cs[:category]
        cs[:category_type].public_categories
      elsif cs[:category]
        if cs[:layer] == 'descendants'
          cs[:category].public_descendants
        else
          cs[:category]
        end
      end
    }.flatten.uniq
  end

  def apply_docs_criteria(courses)
    courses =
      case docs_filter
      when 'public'
        courses.has_public_opens
      when 'available'
        courses.has_available_opens
      end

    courses =
      case docs_order
      when 'id_desc'
        courses.order(id: :desc)
      when 'id_asc'
        courses.order(id: :asc)
      when 'open_at_desc'
        Reception::Course.from('(' + courses.to_sql + ') as reception_courses').order_by_min_open_at('desc')
      when 'open_at_asc'
        Reception::Course.from('(' + courses.to_sql + ') as reception_courses').order_by_min_open_at('asc')
      end

    categories = public_categories
    courses = courses.categorized_into(categories) if categories.present?
    courses.limit(docs_number)
  end

  private

  def validate_docs_number
    if (lc = in_settings['docs_number']).present? && lc !~ /^[0-9]+$/
      errors.add(:docs_number, :not_a_number)
    end
  end

  def set_default_settings
    settings = self.in_settings

    settings['docs_filter'] = 'public' if setting_value(:docs_filter).nil?
    settings['date_style'] = '%Y年%m月%d日' if setting_value(:date_style).nil?
    settings['docs_order'] = DOCS_ORDER_OPTIONS.first.last if setting_value(:docs_order).nil?

    self.in_settings = settings
  end
end
