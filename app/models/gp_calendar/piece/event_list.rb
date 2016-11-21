class GpCalendar::Piece::EventList < Cms::Piece
  default_scope { where(model: 'GpCalendar::EventList') }

  TARGET_DATE_OPTIONS = [['本日以降のイベント', 'near_future'], ['今月開催のイベント', 'this_month']]

  belongs_to :content, :foreign_key => :content_id, :class_name => 'GpCalendar::Content::Event'

  def target_node
    return @target_node if defined? @target_node
    @target_node = content.public_nodes.find_by(id: setting_value(:target_node_id))
  end

  def docs_number
    (setting_value(:docs_number).presence || 10).to_i
  end

  def target_date
    setting_value(:target_date).to_s
  end

  def target_date_text
    TARGET_DATE_OPTIONS.detect{|o| o.last == target_date }.try(:first).to_s
  end

  def category_ids
    setting_value(:category_ids).present? ? YAML.load(setting_value(:category_ids)) : []
  end

  def categories
    GpCategory::Category.where(id: category_ids)
  end

  def categories_label
    categories.pluck(:title).join(',')
  end

  def table_style
    setting_value(:table_style).present? ? YAML.load(setting_value(:table_style)) : [{header: 'タイトル', data: '@title_link@'}]
  end

  def table_style_text
    table_style.map { |v| "#{v[:header]}, #{v[:data]}" }.join(' / ')
  end

  def date_style
    setting_value(:date_style).to_s
  end

  def more_link_label
    setting_value(:more_link_label).to_s
  end

  def more_link_url
    setting_value(:more_link_url).to_s
  end

end
