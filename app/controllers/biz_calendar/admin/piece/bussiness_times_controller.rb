class BizCalendar::Admin::Piece::BussinessTimesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:page_filter, :target_type, :time_style]
  end
end
