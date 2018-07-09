class Gnav::Admin::Piece::CategoryTypesController < Cms::Admin::Piece::BaseController
  def edit
    return error_auth unless @item.readable?

    unless @item.setting_value(:layer)
      in_settings = @item.in_settings
      in_settings['layer'] = @item.class::LAYER_OPTIONS.first.last
      @item.in_settings = in_settings
    end

    _show @item
  end

  private

  def base_params_item_in_settings
    [:category_id, :category_type_id, :layer]
  end
end
