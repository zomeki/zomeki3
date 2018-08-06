class Organization::Content::Group < Cms::Content
  DOCS_ORDER_OPTIONS = [['公開日（降順）', 'published_at_desc'], ['公開日（昇順）', 'published_at_asc'],
                        ['更新日（降順）', 'updated_at_desc'], ['更新日（昇順）', 'updated_at_asc']]

  default_scope { where(model: 'Organization::Group') }

  has_many :settings, foreign_key: :content_id, class_name: 'Organization::Content::Setting', dependent: :destroy
  has_many :groups, foreign_key: :content_id, class_name: 'Organization::Group', dependent: :destroy

  has_many :_reorg_groups, foreign_key: :content_id, class_name: 'Organization::Reorg::Group', dependent: :destroy

  # node
  has_one :node, -> { where(model: 'Organization::Group').order(:id) },
                 foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_node, -> { public_state.where(model: 'Organization::Group').order(:id) },
                        foreign_key: :content_id, class_name: 'Cms::Node'

  def top_layer_sys_groups
    Sys::Group.in_site(site).where(level_no: 2)
  end

  def top_layer_sys_group_codes
    top_layer_sys_groups.pluck(:code)
  end

  def top_layer_groups
    groups.where(sys_group_code: top_layer_sys_group_codes)
  end

  def public_top_layer_groups
    top_layer_groups.public_state
  end

  def find_group_by_path_from_root(path_from_root)
    group_names = path_from_root.split('/')
    return nil if group_names.empty?

    group = top_layer_groups.where(name: group_names.shift).first
    return nil unless group

    group_names.inject(group) {|result, item|
      result.children.where(name: item).first
    }
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

  def list_style
    setting_value(:list_style).to_s
  end

  def doc_style
    setting_value(:doc_style).to_s
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def time_style
    setting_value(:time_style).to_s
  end

  def num_docs
    setting_value(:num_docs).to_i
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def docs_order_as_hash
    map = {
      'published_at_desc' => { display_published_at: :desc, published_at: :desc },
      'published_at_asc' => { display_published_at: :asc, published_at: :asc },
      'updated_at_desc' => { display_updated_at: :desc, updated_at: :desc },
      'updated_at_asc' => { display_updated_at: :asc, updated_at: :asc },
    }
    map[docs_order] || map['published_at_desc']
  end

  def category_content
    GpCategory::Content::CategoryType.where(id: setting_value(:gp_category_content_category_type_id)).first
  end

  def article_contents
    settings = GpArticle::Content::Setting.arel_table
    GpArticle::Content::Doc.joins(:settings)
                           .where(settings[:name].eq('organization_content_group_id'))
                           .where(settings[:value].eq(id))
                           .where(site_id: site_id)
  end

  def docs
    GpArticle::Doc.where(content_id: article_contents.pluck(:id))
  end
end
