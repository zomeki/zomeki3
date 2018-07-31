class GpArticle::Content::Doc < Cms::Content
  default_scope { where(model: 'GpArticle::Doc') }

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'approvable'], ['即時公開', 'public']]

  has_many :settings, foreign_key: :content_id, class_name: 'GpArticle::Content::Setting', dependent: :destroy
  has_many :docs, foreign_key: :content_id, class_name: 'GpArticle::Doc', dependent: :destroy

  # node
  has_one :node, -> { where(model: 'GpArticle::Doc').order(:id) },
                 foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_node, -> { public_state.where(model: 'GpArticle::Doc').order(:id) },
                        foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_archives_node, -> { public_state.where(model: 'GpArticle::Archive').order(:id) },
                                 foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_search_docs_node, -> { public_state.where(model: 'GpArticle::SearchDoc').order(:id) },
                                    foreign_key: :content_id, class_name: 'Cms::Node'

  def docs_for_list
    docs.visible_in_list
  end

  def organization_content_group
    organization_content_group_setting = settings.detect { |st| st.name == 'organization_content_group_id' }
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

  def doc_state_options(user)
    options = STATE_OPTIONS.clone
    options.reject! { |o| o.last == 'public' } if !user.has_auth?(:manager) && !save_button_states.include?('public')
    options.reject! { |o| o.last == 'approvable' } unless approval_related?
    options
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

  def inquiry_default_state
    inquiry_extra_values[:state]
  end

  def inquiry_title
    inquiry_extra_values[:inquiry_title]
  end

  def inquiry_style
    inquiry_extra_values[:inquiry_style]
  end

  def approval_content_approval_flow
    Approval::Content::ApprovalFlow.find_by(id: setting_extra_value(:approval_relation, :approval_content_id))
  end

  def approval_related?
    setting_value(:approval_relation) == 'enabled'
  end

  def publish_after_approved?
    setting_extra_value(:approval_relation, :publish_after_approved) == 'enabled'
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
    { footer_style: setting_extra_value(:blog_functions, :footer_style).to_s }
  end

  def notify_broken_link?
    setting_value(:broken_link_notification) == 'enabled'
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

  def doc_list_period
    setting_extra_value(:doc_list_pagination, :doc_list_period)
  end

  def doc_publish_more_pages
    setting_extra_value(:doc_list_pagination, :doc_publish_more_pages).to_i
  end

  def doc_monthly_title_style
    setting_extra_value(:doc_list_pagination, :doc_monthly_style)
  end

  def doc_weekly_title_style
    setting_extra_value(:doc_list_pagination, :doc_weekly_style)
  end

  def docs_order
    setting_value(:docs_order).to_s
  end

  def docs_order_columns
    if docs_order.blank? || docs_order =~ /^published_at/
      [:display_published_at, :published_at]
    else
      [:display_updated_at, :updated_at]
    end
  end

  def docs_order_column
    docs_order_columns.first
  end

  def docs_order_direction
    docs_order.include?('asc') ? :asc : :desc
  end

  def docs_order_as_hash
    direction = docs_order_direction
    docs_order_columns.each_with_object({}) do |column, hash|
      hash.merge!(column => direction)
    end
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

  def allowed_attachment_types
    allowed_attachment_type.to_s.split(',').map { |type| type.strip.downcase }.select(&:present?)
  end

  def attachment_thumbnail_size
    setting_value(:attachment_thumbnail_size)
  end

  def map_enabled?
    setting_value(:map_setting) == 'enabled'
  end

  def map_coordinate
    setting_extra_value(:map_setting, :lat_lng)
  end

  def word_dictionary
    setting_value(:word_dictionary)
  end

  def related_doc_enabled?
    setting_value(:related_doc) == 'enabled'
  end

  def link_check_enabled?
    setting_value(:link_check) == 'enabled'
  end

  def accessibility_check_enabled?
    setting_value(:accessibility_check) == 'enabled'
  end

  def navigation_enabled?
    setting_value(:navigation_setting) == 'enabled'
  end

  def navigation_target_types
    setting_extra_value(:navigation_setting, :types)
  end

end
