class AdBanner::Admin::Piece::BannersController < Cms::Admin::Piece::BaseController
  private

  def base_params
    params.require(:item).permit(:body, :concept_id, :name, :state, :title, :view_title,
                                 in_creator: [:group_id, :user_id],
                                 in_settings: [:group_id, :sort, :upper_text, :lower_text])
  end
end
