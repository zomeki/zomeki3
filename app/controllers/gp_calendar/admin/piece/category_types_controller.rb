class GpCalendar::Admin::Piece::CategoryTypesController < GpCalendar::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:target_node_id]
  end
end
