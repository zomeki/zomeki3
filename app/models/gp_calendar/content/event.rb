class GpCalendar::Content::Event < Cms::Content
  default_scope { where(model: 'GpCalendar::Event') }

  has_one :public_node, -> { public_state.order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'GpCalendar::Content::Setting', dependent: :destroy

  has_many :events, foreign_key: :content_id, class_name: 'GpCalendar::Event', dependent: :destroy
  has_many :holidays, foreign_key: :content_id, class_name: 'GpCalendar::Holiday', dependent: :destroy

  after_create :create_default_holidays

  def public_events
    events.public_state
  end

  def public_holidays
    holidays.public_state
  end

  def category_content_id
    setting_value(:gp_category_content_category_type_id).to_i
  end

  def category_types
    category_type_ids = setting_extra_value(:gp_category_content_category_type_id, :category_type_ids).to_a
    GpCategory::CategoryType.where(id: category_type_ids)
  end

  def public_category_types
    category_types.public_state
  end

  def category_type_categories(category_type)
    category_type_id = (category_type.kind_of?(GpCategory::CategoryType) ? category_type.id : category_type.to_i )
    category_type = category_types.detect {|ct| ct.id == category_type_id }
    category_type ? category_type.public_root_categories : GpCategory::Category.none
  end

  def category_type_categories_for_option(category_type, include_descendants: true)
    if include_descendants
      category_type_categories(category_type).map{|c| c.descendants_for_option }.flatten(1)
    else
      category_type_categories(category_type).map {|c| [c.title, c.id] }
    end
  end

  def list_style
    setting_value(:list_style)
  end

  def today_list_style
    setting_value(:today_list_style)
  end

  def calendar_list_style
    setting_value(:calendar_list_style).to_s
  end

  def search_list_style
    setting_value(:search_list_style)
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def show_images?
    setting_value(:show_images) == 'visible'
  end

  def default_image
    setting_value(:default_image).to_s
  end

  def image_cnt
    setting_extra_value(:show_images, :image_cnt).to_i
  end

  def allowed_attachment_type
    'gif,jpg,png'
  end

  def attachment_embed_link
    false
  end

  def public_event_docs(start_date, end_date, categories = nil)
    doc_content_ids = Cms::ContentSetting.where(name: 'calendar_relation', value: 'enabled')
                                         .select { |cs| cs.extra_values[:calendar_content_id] == id }
                                         .map(&:content_id)
    if doc_content_ids.blank?
      GpArticle::Doc.none
    else
      GpArticle::Doc.mobile(::Page.mobile?).public_state
                    .where(content_id: doc_content_ids, event_state: 'visible')
                    .event_scheduled_between(start_date, end_date, categories)
    end
  end

  private

  def create_default_holidays
    GpCalendar::DefaultHolidayJob.perform_now(id)
  end
end
