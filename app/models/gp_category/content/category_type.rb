class GpCategory::Content::CategoryType < Cms::Content
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'published_at_desc'], ['公開日（昇順）', 'published_at_asc'],
                        ['更新日（降順）', 'updated_at_desc'], ['更新日（昇順）', 'updated_at_asc']]

  default_scope { where(model: 'GpCategory::CategoryType') }

  has_one :public_node, -> { public_state.where(model: 'GpCategory::CategoryType').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'GpCategory::Content::Setting', dependent: :destroy

  has_many :category_types, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'GpCategory::CategoryType', dependent: :destroy
  has_many :templates, foreign_key: :content_id, class_name: 'GpCategory::Template', dependent: :destroy
  has_many :template_modules, foreign_key: :content_id, class_name: 'GpCategory::TemplateModule', dependent: :destroy

  def public_category_types
    category_types.public_state
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
  end

  def public_pieces_for_doc_list
    public_pieces.where(model: ['GpCategory::CategoryType', 'GpCategory::Doc', 'GpCategory::RecentTab'])
  end

  def templates_with_name(names)
    arel = templates.arel_table
    templates.where(names.map { |name| arel[:body].matches("%[[module/#{name}]]%") }.reduce(:or))
  end

  def list_style
    setting_value(:list_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def time_style
    setting_value(:time_style).to_s
  end

  def category_type_style
    setting_value(:category_type_style).to_s
  end

  def category_type_doc_style
    setting_extra_value(:category_type_style, :category_type_doc_style).to_s
  end

  def category_type_docs_number
    (setting_extra_value(:category_type_style, :category_type_docs_number).presence || 1000).to_i
  end

  def category_style
    setting_value(:category_style).to_s
  end

  def category_doc_style
    setting_extra_value(:category_style, :category_doc_style).to_s
  end

  def category_docs_number
    (setting_extra_value(:category_style, :category_docs_number).presence || 1000).to_i
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def doc_doc_style
    setting_extra_value(:doc_style, :doc_doc_style).to_s
  end

  def doc_docs_number
    (setting_extra_value(:doc_style, :doc_docs_number).presence || 1000).to_i
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def translated_docs_order
    map = {
      'published_at_desc' => 'display_published_at DESC, published_at DESC',
      'published_at_asc' => 'display_published_at ASC, published_at ASC',
      'updated_at_desc' => 'display_updated_at DESC, updated_at DESC',
      'updated_at_asc' => 'display_updated_at ASC, updated_at ASC'
    }
    map[docs_order] || map['published_at_desc']
  end

  def feed_display?
    setting_value(:feed) != 'disabled'
  end

  def feed_docs_number
    (setting_extra_value(:feed, :feed_docs_number).presence || 10).to_i
  end

  def feed_docs_period
    setting_extra_value(:feed, :feed_docs_period)
  end

  def index_template
    templates.find_by(id: setting_value(:index_template_id))
  end
end
