module GpCategory::Model::Rel::Content::Setting::CategoryTypeId
  extend ActiveSupport::Concern

  def extra_values=(params)
    ex = extra_values
    case name
    when 'gp_category_content_category_type_id'
      ex[:category_type_ids] = Array(params[:category_types]).map(&:to_i)
      ex[:visible_category_type_ids] = Array(params[:visible_category_types]).map(&:to_i)
      ex[:default_category_type_id] = params[:default_category_type].to_i
      ex[:default_category_id] = params[:default_category].to_i
    end
    super(ex)
  end

  def category_type_ids
    extra_values[:category_type_ids] || []
  end

  def visible_category_type_ids
    extra_values[:visible_category_type_ids] || []
  end

  def default_category_type_id
    extra_values[:default_category_type_id] || 0
  end

  def default_category_id
    extra_values[:default_category_id] || 0
  end
end
