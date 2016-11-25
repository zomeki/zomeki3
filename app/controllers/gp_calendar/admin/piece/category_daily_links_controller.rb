class GpCalendar::Admin::Piece::CategoryDailyLinksController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    item_in_settings[:target_node_id] = params[:target_node]
    if (ids = params[:categories]).is_a?(Array)
      category_ids = ids.map{|id| id.to_i if id.present? }.compact.uniq
      item_in_settings[:category_ids] = YAML.dump(category_ids)
    end
    params[:item][:in_settings]       = item_in_settings
    super
  end

  private

  def base_params_item_in_settings
    [:target_node_id, :category_ids]
  end
end
