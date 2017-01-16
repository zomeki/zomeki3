class Organization::Content::Group < Cms::Content
  default_scope { where(model: 'Organization::Group') }

  has_one :public_node, -> { public_state.where(model: 'Organization::Group').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Organization::Content::Setting', dependent: :destroy

  has_many :groups, foreign_key: :content_id, class_name: 'Organization::Group', dependent: :destroy

  def refresh_groups
    sys_groups = top_layer_sys_groups.flat_map { |g| g.descendants_in_site(site) }
    sys_groups.each do |sys_group|
      group = groups.where(sys_group_code: sys_group.code).first_or_create(name: sys_group.name_en)
      unless group.valid?
        group.name = "#{sys_group.name_en}_#{sys_group.code}"
        group.save
      end
    end

    groups.each do |group|
      sys_group = group.sys_group
      group.destroy if sys_group.nil? || !sys_group.sites.include?(site)
    end
  end

  def top_layer_sys_groups
    Sys::Group.in_site(site).where(level_no: 2)
  end

  def top_layer_sys_group_codes
    top_layer_sys_groups.pluck(:code)
  end

  def top_layer_groups
    groups.where(sys_group_code: top_layer_sys_group_codes)
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

  def article_related?
    setting_value(:article_relation) == 'enabled'
  end

  def related_article_content_id
    setting_extra_value(:article_relation, :gp_article_content_doc_id)
  end

  def related_article_content
    return @related_article_content if defined? @related_article_content
    @related_article_content = GpArticle::Content::Doc.find_by(id: setting_extra_value(:article_relation, :gp_article_content_doc_id))
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

  def category_content
    GpCategory::Content::CategoryType.where(id: setting_value(:gp_category_content_category_type_id)).first
  end
end
