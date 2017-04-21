class Map::Content::Marker < Cms::Content
  default_scope { where(model: 'Map::Marker') }

  has_one :public_node, -> { public_state.where(model: 'Map::Marker').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'Map::Content::Setting', dependent: :destroy

  has_many :markers, foreign_key: :content_id, class_name: 'Map::Marker', dependent: :destroy
  has_many :marker_icons, foreign_key: :content_id, class_name: 'Map::MarkerIcon', dependent: :destroy

  def public_markers
    markers.public_state
  end

  def latitude
    lat_lng = setting_value(:lat_lng).to_s.split(',')
    map_coordinate = Cms::SiteSetting.find_by(site_id: site.id, name: 'map_coordinate').try(:value).to_s.split(',')
    default_map_coordinate = Zomeki.config.application["cms.default_map_coordinate"].to_s.split(',')
    return lat_lng.first.strip if lat_lng.size == 2
    return map_coordinate.first.strip if map_coordinate.size == 2
    default_map_coordinate.first.strip
  end

  def longitude
    lat_lng = setting_value(:lat_lng).to_s.split(',')
    map_coordinate = Cms::SiteSetting.find_by(site_id: site.id, name: 'map_coordinate').try(:value).to_s.split(',')
    default_map_coordinate = Zomeki.config.application["cms.default_map_coordinate"].to_s.split(',')
    return lat_lng.last.strip if lat_lng.size == 2
    return map_coordinate.last.strip if map_coordinate.size == 2
    default_map_coordinate.last.strip
  end

  def categories
    setting = Map::Content::Setting.find_by(id: settings.find_by(name: 'gp_category_content_category_type_id').try(:id))
    return GpCategory::Category.none unless setting
    setting.categories
  end

  def public_categories
    categories.public_state
  end

  def category_types
    GpCategory::CategoryType.where(id: categories.map(&:category_type_id))
  end

  def category_types_for_option
    category_types.map {|ct| [ct.title, ct.id] }
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

  def icon_categories_for_option
    marker_icons.where(relatable_type: 'GpCategory::Category').preload(:relatable)
      .select { |icon| icon.relatable.present? }
      .map { |icon| ["#{icon.relatable.title}（#{icon.relatable.category_type.title}） - #{icon.url}", icon.relatable.id] }
  end

  def icon_image(item, goup = false)
    if (icon = marker_icons.where(relatable: item).first)
      icon.url
    else
      if item == GpCategory::Category && goup
        icon_image(item.parent || item.category_type, goup)
      else
        ''
      end
    end
  end

  def show_images?
    setting_value(:show_images) == 'visible'
  end

  def default_image
    setting_value(:default_image).to_s
  end

  def title_style
    setting_value(:title_style).to_s
  end

  def sort_markers(markers)
    case setting_value(:marker_order)
    when 'time_asc'
      markers.sort {|a, b| a.created_at <=> b.created_at }
    when 'time_desc'
      markers.sort {|a, b| b.created_at <=> a.created_at }
    when 'category'
      markers.sort do |a, b|
        next  0 if a.categories.empty? && b.categories.empty?
        next -1 if a.categories.empty?
        next  1 if b.categories.empty?
        a.categories.first.unique_sort_key <=> b.categories.first.unique_sort_key
      end
    else
      markers
    end
  end

  def public_marker_docs(specified_category = nil)
    contents = GpArticle::Content::Doc.arel_table
    content_settings = Cms::ContentSetting.arel_table
    doc_content_ids = GpArticle::Content::Doc.joins(:settings)
                                             .where(contents[:site_id].eq(site_id))
                                             .where(content_settings[:name].eq('map_relation'))
                                             .where(content_settings[:value].eq('enabled'))
                                             .select { |d| d.setting_extra_value(:map_relation, :map_content_id) == id }
                                             .map(&:id)
    if doc_content_ids.blank?
      GpArticle::Doc.none
    else
      docs = GpArticle::Doc.joins(maps: :markers).mobile(::Page.mobile?).public_state
                           .where(content_id: doc_content_ids, marker_state: 'visible')
      if specified_category
        cat_ids = GpCategory::Categorization.select(:categorizable_id)
                                            .where(categorized_as: 'Map::Marker')
                                            .where(category_id: specified_category.public_descendants.map(&:id))
        docs = docs.where(id: cat_ids)
      end
      docs
    end
  end
end
