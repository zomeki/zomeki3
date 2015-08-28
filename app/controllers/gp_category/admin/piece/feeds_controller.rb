# encoding: utf-8
class GpCategory::Admin::Piece::FeedsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:filename]
  end
end
