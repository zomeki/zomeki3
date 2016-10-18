class Organization::Content::Group < Cms::Content
  ARTICLE_RELATION_OPTIONS = [['使用する', 'enabled'], ['使用しない', 'disabled']]

  default_scope { where(model: 'Organization::Group') }

  has_one :public_node, -> { public_state.order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Organization::Content::Setting', dependent: :destroy

  has_many :groups, foreign_key: :content_id, class_name: 'Organization::Group', dependent: :destroy

  def public_nodes
    nodes.public_state
  end

  def refresh_groups
    return unless root_sys_group

    root_sys_group.children.each do |child|
      next if (root_sys_group.sites & child.sites).empty?
      copy_from_sys_group(child)
    end

    groups.each do |group|
      group.destroy if group.sys_group.nil? ||
                       (root_sys_group.sites & group.sys_group.sites).empty?
    end
  end

  def root_sys_group
    return unless site_id
    belongings = Cms::SiteBelonging.arel_table
    Sys::Group.joins(:site_belongings).where(belongings[:site_id].eq(site_id))
              .where(parent_id: 0, level_no: 1).first
  end

  def root_groups
    sys_group_codes = root_sys_group.children.pluck(:code)
    groups.where(sys_group_code: sys_group_codes)
  end

  def find_group_by_path_from_root(path_from_root)
    group_names = path_from_root.split('/')
    return nil if group_names.empty?

    sys_group_codes = root_sys_group.children.pluck(:code)
    group = groups.where(sys_group_code: sys_group_codes, name: group_names.shift).first
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

  private

  def copy_from_sys_group(sys_group)
    group = groups.where(sys_group_code: sys_group.code).first_or_create(name: sys_group.name_en)
    unless group.valid?
      group.name = "#{sys_group.name_en}_#{sys_group.code}"
      group.save
    end
    unless sys_group.children.empty?
      sys_group.children.each do |child|
        next if (sys_group.sites & child.sites).empty?
        copy_from_sys_group(child)
      end
    end
  end
end
