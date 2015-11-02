class GpCalendar::Admin::Piece::MonthlyLinksController < GpCalendar::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:target_node_id]
  end
end
