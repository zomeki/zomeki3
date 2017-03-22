class Reception::Admin::Piece::CoursesController < Cms::Admin::Piece::BaseController
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

    params[:item][:in_settings] = item_in_settings

    super
  end

  private

  def base_params_item_in_settings
    [:docs_filter, :docs_order, :date_style, :doc_style, :docs_number, :more_link_body, :more_link_url, :category_sets]
  end
end
