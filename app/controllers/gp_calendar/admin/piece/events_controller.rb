class GpCalendar::Admin::Piece::EventsController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    item_in_settings[:target_node_id] = params[:target_node]
    if (ids = params[:categories]).is_a?(Array)
      category_ids = ids.map{|id| id.to_i if id.present? }.compact.uniq
      item_in_settings[:category_ids] = YAML.dump(category_ids)
    end
    if (table_field = params[:table_style]).is_a?(Array)
      table_style = table_field.map{|n| {header: n[:header], data: n[:data]} }.compact.uniq
      item_in_settings[:table_style] = YAML.dump(table_style)
    end
    params[:item][:in_settings]       = item_in_settings
    super
  end

  private

  def base_params_item_in_settings
    [:docs_number, :category_ids, :table_style, :date_style,
      :more_link_label, :more_link_url, :target_date]
  end
end
