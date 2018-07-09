class Organization::Admin::Piece::CategorizedDocsController < Cms::Admin::Piece::BaseController
  def update
    @item.attributes = base_params
    @item.updated_at = Time.now
    @item.category_ids = if params[:categories]
                           params[:categories].values.flatten.map{|c| c.to_i if c.present? }.compact.uniq
                         else
                           []
                         end
    _update @item, location: cms_pieces_url
  end

  private

  def base_params_item_in_settings
    [:list_count, :docs_order, :doc_style, :date_style, :page_filter]
  end
end
