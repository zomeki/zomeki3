class Reception::Admin::Piece::CoursesController < Cms::Admin::Piece::BaseController
  private

  def base_params_item_in_settings
    [:docs_filter, :docs_order, :date_style, :doc_style, :docs_number, :more_link_body, :more_link_url]
  end
end
