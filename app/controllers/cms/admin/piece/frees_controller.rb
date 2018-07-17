class Cms::Admin::Piece::FreesController < Cms::Admin::Piece::BaseController
  before_action :check_duplicated_piece, only: [:edit]

  private

  def check_duplicated_piece
    item = if @item.replaced_page?
             @item.replaced_page
           elsif @item.state == 'public'
             @item.duplicate(:replace)
           end
    redirect_to url_for(action: :edit, id: item) if item
  end

  def base_params_item
    [:body, :concept_id, :name, :state, :title, :view_title]
  end
end
