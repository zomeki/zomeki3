class BizCalendar::Admin::Piece::BussinessHolidaysController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:date_style, :page_filter, :place_link, :target_type]
  end
end
