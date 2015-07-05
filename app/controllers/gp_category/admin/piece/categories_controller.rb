class GpCategory::Admin::Piece::CategoriesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:category_type_id, :num_docs_visibility]
  end
end
