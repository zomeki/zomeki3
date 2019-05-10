class GpArticle::Admin::Piece::SearchDocsController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    if (ids = params[:item][:in_category_type_ids]).is_a?(Array)
      category_type_ids = ids.map{|id| id.to_i if id.present? }.compact.uniq
      item_in_settings[:category_type_ids] = YAML.dump(category_type_ids)
    end
    params[:item][:in_settings] = item_in_settings
    super
  end

  private

  def base_params_item_in_settings
    [:operator_type, :category_type_ids ]
  end
end
