class GpArticle::Content::Doc < Cms::Content
  default_scope { where(model: 'GpArticle::Doc') }

  has_one :public_node, -> { public_state.where(model: 'GpArticle::Doc').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :doc_node, -> { where(model: 'GpArticle::Doc').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_archives_node, -> { public_state.where(model: 'GpArticle::Archive').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'GpArticle::Content::Setting', dependent: :destroy
  has_one :organization_content_group_setting, -> { where(name: 'organization_content_group_id') },
    foreign_key: :content_id, class_name: 'GpArticle::Content::Setting'

  has_many :docs, foreign_key: :content_id, class_name: 'GpArticle::Doc', dependent: :destroy

  # draft, approvable, approved, public, finish, archived
  def all_docs
    docs.unscoped.where(content_id: id).mobile(::Page.mobile?)
  end

  # draft, approvable, approved, public
  def preview_docs
    table = docs.arel_table
    docs.mobile(::Page.mobile?).where(table[:state].not_eq('finish'))
  end

  # public
  def public_docs
    docs.mobile(::Page.mobile?).public_state
  end

  def public_docs_for_list
    public_docs.visible_in_list
  end

  def published_first_day
    public_docs.visible_in_list.order(display_published_at: :desc, published_at: :desc).first.try(:display_published_at) || Date.today
  end

  def published_last_day
    public_docs.visible_in_list.order(display_published_at: :asc, published_at: :asc).first.try(:display_published_at) || Date.today
  end

  def organization_content_group
    if organization_content_group_setting
      @organization_content_group ||= organization_content_group_setting.organization_content_group
    end
  end

  def gp_category_content_category_type
    GpCategory::Content::CategoryType.find_by(id: setting_value(:gp_category_content_category_type_id))
  end

  def category_types
    setting = GpArticle::Content::Setting.find_by(id: settings.find_by(name: 'gp_category_content_category_type_id').try(:id))
    if (cts = gp_category_content_category_type.try(:category_types))
      cts.where(id: setting.try(:category_type_ids))
    else
      GpCategory::CategoryType.none
    end
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
  end

  def visible_category_types
    setting = GpArticle::Content::Setting.find_by(id: settings.find_by(name:  'gp_category_content_category_type_id').try(:id))
    if (cts = gp_category_content_category_type.try(:category_types))
      cts.where(id: setting.try(:visible_category_type_ids))
    else
      GpCategory::CategoryType.none
    end
  end

  def default_category_type
    setting = GpArticle::Content::Setting.find_by(id: settings.find_by(name: 'gp_category_content_category_type_id').try(:id))
    GpCategory::CategoryType.find_by(id: setting.try(:default_category_type_id))
  end

  def default_category
    setting = GpArticle::Content::Setting.find_by(id: settings.find_by(name: 'gp_category_content_category_type_id').try(:id))
    GpCategory::Category.find_by(id: setting.try(:default_category_id))
  end

  def doc_list_lang
    setting_value(:doc_list_lang).to_sym
  end

  def prev_label
    setting_value(:pagination_label).to_s
  end

  def next_label
    setting_extra_value(:pagination_label, :next_label).to_s
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

  def tag_related?
    setting_value(:tag_relation) == 'enabled'
  end

  def tag_content_tag
    Tag::Content::Tag.find_by(id: setting_extra_value(:tag_relation, :tag_content_tag_id))
  end

  def save_button_states
    setting_value(:save_button_states) || []
  end

  def display_dates(key)
    (setting_value(:display_dates) || []).include?(key.to_s)
  end

  def gp_calendar_content_event
    GpCalendar::Content::Event.find_by(id: setting_extra_value(:calendar_relation, :calendar_content_id))
  end

  def event_category_types
    gp_calendar_content_event.try(:category_types) || GpCategory::CategoryType.none
  end

  def event_category_type_categories_for_option(category_type, include_descendants: true)
    gp_calendar_content_event.try(:category_type_categories_for_option,
                                  category_type, include_descendants: include_descendants) || []
  end

  def calendar_related?
    setting_value(:calendar_relation) == 'enabled'
  end

  def map_content_marker
    Map::Content::Marker.find_by(id: setting_extra_value(:map_relation, :map_content_id))
  end

  def marker_category_types
    map_content_marker.try(:category_types) || GpCategory::CategoryType.none
  end

  def marker_category_type_categories_for_option(category_type, include_descendants: true)
    map_content_marker.try(:category_type_categories_for_option,
                           category_type, include_descendants: include_descendants) || []
  end

  def marker_icon_category_enabled?
    setting_extra_value(:map_relation, :marker_icon_category) == 'enabled'
  end

  def map_related?
    setting_value(:map_relation) == 'enabled'
  end

  def inquiry_related?
    setting_value(:inquiry_setting) == 'enabled'
  end

  def inquiry_extra_values
    setting_extra_values(:inquiry_setting) || {}
  end

  def approval_content_approval_flow
    Approval::Content::ApprovalFlow.find_by(id: setting_extra_value(:approval_relation, :approval_content_id))
  end

  def approval_related?
    setting_value(:approval_relation) == 'enabled'
  end

  def template_available?
    gp_temlate_content_template.present? && templates.present?
  end

  def gp_temlate_content_template
    return nil if setting_value(:gp_template_content_template_id).blank?
    GpTemplate::Content::Template.where(id: setting_value(:gp_template_content_template_id)).first
  end

  def templates
    return GpTemplate::Template.none if setting_value(:gp_template_content_template_id).blank?
    GpTemplate::Template.where(id: setting_extra_value(:gp_template_content_template_id, :template_ids))
  end

  def default_template
    return nil if setting_value(:gp_template_content_template_id).blank?
    GpTemplate::Template.where(id: setting_extra_value(:gp_template_content_template_id, :default_template_id)).first
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

  def blog_functions_available?
    setting_value(:blog_functions) == 'enabled'
  end

  def blog_functions
    {comment: setting_extra_value(:blog_functions, :comment) == 'enabled',
     comment_open: setting_extra_value(:blog_functions, :comment_open) == 'immediate',
     comment_notification_mail: setting_extra_value(:blog_functions, :comment_notification_mail) == 'enabled',
     footer_style: setting_extra_value(:blog_functions, :footer_style).to_s}
  end

  def comments
    rel = GpArticle::Comment.joins(:doc)

    docs = GpArticle::Doc.arel_table
    rel = rel.where(docs[:content_id].eq(self.id))

    return rel
  end

  def public_comments
    docs = GpArticle::Doc.arel_table
    comments.where(docs[:state].eq('public')).public_state
  end

  def notify_broken_link?
    setting_value(:broken_link_notification) == 'enabled'
  end

  def public_path
    site.public_path
  end

  def feature_settings_enabled?
    setting_value(:feature_settings) == 'enabled'
  end

  def feature_settings
    {feature_1: setting_extra_value(:feature_settings, :feature_1) != 'false',
     feature_2: setting_extra_value(:feature_settings, :feature_2) != 'false'}
  end

  def wrapper_tag
    setting_extra_value(:list_style, :wrapper_tag) || 'li'
  end

  def doc_list_pagination
    setting_value(:doc_list_pagination)
  end

  def monthly_pagination?
    setting_value(:doc_list_pagination) == 'monthly'
  end

  def weekly_pagination?
    setting_value(:doc_list_pagination) == 'weekly'
  end

  def simple_pagination?
    setting_value(:doc_list_pagination) == 'simple'
  end

  def doc_list_style
    setting_extra_value(:doc_list_pagination, :doc_list_style).to_s
  end

  def doc_list_number
    setting_extra_value(:doc_list_pagination, :doc_list_number).to_i
  end

  def doc_publish_more_pages
    setting_extra_value(:doc_list_pagination, :doc_publish_more_pages).to_i
  end

  def doc_monthly_style
    setting_extra_value(:doc_list_pagination, :doc_monthly_style)
  end

  def rel_docs_style
    setting_value(:rel_docs_style).to_s
  end

  def qrcode_related?
    setting_value(:qrcode_settings) == 'enabled'
  end

  def qrcode_default_state
    setting_extra_value(:qrcode_settings, :state) || 'hidden'
  end

  def event_sync?
    setting_extra_value(:calendar_relation, :event_sync_settings) == 'enabled'
  end

  def event_sync_default_will_sync
    setting_extra_value(:calendar_relation, :event_sync_default_will_sync).to_s
  end

  def serial_no_enabled?
    setting_value(:serial_no_settings) == 'enabled'
  end

  def serial_no_title
    setting_extra_value(:serial_no_settings, :title)
  end

  def lang_options
    lang = setting_value(:lang)
    lang.to_s.split(',').map { |str| str.split(' ') }
  end

  def allowed_attachment_type
    setting_value(:allowed_attachment_type)
  end

  def attachment_thumbnail_size
    setting_value(:attachment_thumbnail_size)
  end
end
