class GpCalendar::Content::Event < Cms::Content
  default_scope { where(model: 'GpCalendar::Event') }

  has_one :public_node, -> { public_state.order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'GpCalendar::Content::Setting', dependent: :destroy

  has_many :events, foreign_key: :content_id, class_name: 'GpCalendar::Event', dependent: :destroy
  has_many :holidays, foreign_key: :content_id, class_name: 'GpCalendar::Holiday', dependent: :destroy

  def public_events
    events.public_state
  end

  def public_holidays
    holidays.public_state
  end

  def category_content_id
    setting_value(:gp_category_content_category_type_id).to_i
  end

  def categories
    setting = GpCalendar::Content::Setting.find_by(id: settings.find_by(name: 'gp_category_content_category_type_id').try(:id))
    return GpCategory::Category.none unless setting
    setting.categories
  end

  def categories_for_option
    categories.map {|c| [c.title, c.id] }
  end

  def public_categories
    categories.public_state
  end

  def category_types
    setting = GpCalendar::Content::Setting.find_by(id: settings.find_by(name: 'gp_category_content_category_type_id').try(:id))
    return GpCategory::CategoryType.none unless setting
    setting.category_types
  end

  def category_type_categories(category_type)
    category_type_id = (category_type.kind_of?(GpCategory::CategoryType) ? category_type.id : category_type.to_i )
    categories.select {|c| c.category_type_id == category_type_id }
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

  def event_sync_import?
    setting_value(:event_sync_import) == 'enabled'
  end

  def event_sync_export?
    setting_value(:event_sync_export) == 'enabled'
  end

  def event_sync_source_hosts
    setting_extra_value(:event_sync_import, :source_hosts).to_s
  end

  def event_sync_destination_hosts
    setting_extra_value(:event_sync_export, :destination_hosts).to_s
  end

  def event_sync_default_will_sync
    setting_extra_value(:event_sync_export, :default_will_sync).to_s
  end
end
