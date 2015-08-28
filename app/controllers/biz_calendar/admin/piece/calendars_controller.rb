class BizCalendar::Admin::Piece::CalendarsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:date_style, :holiday_state, :holiday_type_state, :lower_text, :month_number, :place_id]
  end
end
