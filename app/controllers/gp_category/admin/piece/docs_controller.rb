class GpCategory::Admin::Piece::DocsController < Cms::Admin::Piece::BaseController
  def update
    item_in_settings = (params[:item][:in_settings] || {})

    if (category_types = params[:category_types]) &&
       (categories = params[:categories]) &&
       (layers = params[:layers])
      category_sets = []

      category_types.each do |key, value|
        category_type_id = value.to_i
        category_id = categories[key].to_i

        next if category_sets.any? {|cs| cs[:category_type_id] == category_type_id &&
                                         cs[:category_id] == category_id }
        next if GpCategory::CategoryType.where(id: category_type_id).empty?
        next if category_id.nonzero? && GpCategory::Category.where(id: category_id).empty?

        category_set = @piece.new_category_set
        category_set[:category_type_id] = category_type_id
        category_set[:category_id] = category_id
        category_set[:layer] = layers[key].to_s unless category_id.zero?

        category_sets << category_set
      end

      item_in_settings[:category_sets] = YAML.dump(category_sets)
    end

    if (gp_article_content_docs = params[:gp_article_content_docs]).is_a?(Array)
      item_in_settings[:gp_article_content_doc_ids] = YAML.dump(gp_article_content_docs.map{|d| d.to_i if d.present? }.compact.uniq)
    end

    params[:item][:in_settings] = item_in_settings

    super
  end

  private

  def find_piece
    model.readable.find(params[:id])
  end

  def base_params_item_in_settings
    [:date_style, :doc_style, :docs_order, :list_count, :more_link_body, :more_link_url, :page_filter,
      :category_sets, :gp_article_content_doc_ids]
  end
end
