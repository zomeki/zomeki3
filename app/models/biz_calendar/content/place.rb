class BizCalendar::Content::Place < Cms::Content

  default_scope { where(model: 'BizCalendar::Place') }

  has_one :public_node, -> { public_state.where(model: 'BizCalendar::Place').order(:id) },
    foreign_key: :content_id, class_name: 'Cms::Node'

  has_many :settings, -> { order(:sort_no) },
    foreign_key: :content_id, class_name: 'BizCalendar::Content::Setting', dependent: :destroy

  has_many :places, foreign_key: :content_id, class_name: 'BizCalendar::Place', dependent: :destroy
  has_many :types, foreign_key: :content_id, class_name: 'BizCalendar::HolidayType', dependent: :destroy

  def public_places
    places.public_state
  end

  def visible_types
    types.visible
  end

  def month_number
    setting_value(:month_number).to_i
  end

  def show_month_number
    setting_value(:show_month_number).to_i
  end

  def date_style
    setting_value(:date_style).to_s.present? ? setting_value(:date_style).to_s : '%Y年%m月%d日 %H時%M分'
  end

  def time_style
    setting_value(:time_style).to_s.present? ? setting_value(:time_style).to_s : '%H時%M分'
  end
end