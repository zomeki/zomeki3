class GpCalendar::Content::Event < Cms::Content
  IMAGE_STATE_OPTIONS = [['表示', 'visible'], ['非表示', 'hidden']]
  EVENT_SYNC_OPTIONS = [['有効', 'enabled'], ['無効', 'disabled']]

  default_scope { where(model: 'GpCalendar::Event') }

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'GpCalendar::Content::Setting', dependent: :destroy

  has_many :events, foreign_key: :content_id, class_name: 'GpCalendar::Event', dependent: :destroy
  has_many :holidays, foreign_key: :content_id, class_name: 'GpCalendar::Holiday', dependent: :destroy

  def public_nodes
    nodes.public_state
  end

  def public_node
    public_nodes.order(:id).first
  end

  def public_events
    events.public_state
  end

  def public_holidays
    holidays.public_state
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
    GpCategory::CategoryType.where(id: categories.map(&:category_type_id))
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
    setting_value(:list_style).to_s
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
