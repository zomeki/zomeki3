class Survey::Admin::Piece::FormsController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:head_css, :lower_text, :target_form_id, :upper_text]
  end
end
