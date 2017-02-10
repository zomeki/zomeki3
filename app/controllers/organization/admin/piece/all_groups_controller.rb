class Organization::Admin::Piece::AllGroupsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:list_style]
  end
end
