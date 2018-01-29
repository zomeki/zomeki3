class Organization::Piece::CategorizedDoc < Cms::Piece
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'published_at_desc'], ['公開日（昇順）', 'published_at_asc'],
                        ['更新日（降順）', 'updated_at_desc'], ['更新日（昇順）', 'updated_at_asc']]
  PAGE_FILTER_OPTIONS = [['下位の組織を含む', 'descendants'], ['下位の組織を含まない', 'self']]

  default_scope { where(model: 'Organization::CategorizedDoc') }

  belongs_to :content, :foreign_key => :content_id, :class_name => 'Organization::Content::Group'

  after_initialize :set_default_settings

  store :etcetera, accessors: [:category_ids]

  def list_count
    (setting_value(:list_count).presence || 1000).to_i
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def docs_order_as_hash
    docs_order_text_to_hash(docs_order)
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def page_filter
    setting_value(:page_filter).to_s
  end

  def category_ids=(ids)
    etcetera[:category_ids] = ids.to_a
  end

  def category_ids
    etcetera[:category_ids].to_a
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end

  private

  def set_default_settings
    settings = self.in_settings

    settings['date_style'] = '%Y年%m月%d日 %H時%M分' if setting_value(:date_style).nil?
    settings['docs_order'] = 'published_at_desc' if setting_value(:docs_order).nil?
    settings['page_filter'] = 'descendants' if setting_value(:page_filter).nil?

    self.in_settings = settings
  end

  def docs_order_text_to_hash(docs_order)
    case docs_order
    when 'published_at_desc'
      { display_published_at: :desc, published_at: :desc }
    when 'published_at_asc'
      { display_published_at: :asc, published_at: :asc }
    when 'updated_at_desc'
      { display_updated_at: :desc, updated_at: :desc }
    when 'updated_at_asc'
      { display_updated_at: :asc, updated_at: :asc }
    end
  end
end
