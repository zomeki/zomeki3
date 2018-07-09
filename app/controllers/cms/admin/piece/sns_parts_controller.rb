class Cms::Admin::Piece::SnsPartsController < Cms::Admin::Piece::BaseController
  def update
    in_settings = {}
    item_in_settings = (params[:item][:in_settings] || {})
    @item.class::SETTING_KEYS.each {|k| in_settings[k] = item_in_settings[k] }
    params[:item][:in_settings] = in_settings
    super
  end

  private

  def base_params_item_in_settings
    [:fb_like, :g_plusone, :line, :mixi, :mixi_data_key, :twitter]
  end
end
