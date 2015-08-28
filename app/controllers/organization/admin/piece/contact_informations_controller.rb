class Organization::Admin::Piece::ContactInformationsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:source]
  end
end
