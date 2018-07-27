class GpArticle::Admin::Aggregation::CategoriesController < Cms::Controller::Admin::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @category_types = @content.visible_category_types
    @state_options = GpArticle::Doc.state_options(except: 'archived')

    @category_map = @category_types.each_with_object({}) do |ct, hash|
                      hash[ct.id] = ct.categories.to_tree.flat_map(&:descendants)
                    end

    docs = GpArticle::Doc.arel_table
    categorization = GpCategory::Categorization.arel_table
    items = @content.docs.joins(:categorizations)
                    .select(docs[:state], categorization[:category_id], docs[:state].count.as('count'))
                    .group(docs[:state], categorization[:category_id])

    @category_count = make_category_count(items)
    @state_count = make_state_count(items)

    @category_total = total_by_category
    @state_total = total_by_state
  end

  private

  def select_by_category_type(items, category_type)
    items.select { |item| category_type.category_ids.include?(item.category_id) }
  end

  def make_category_count(items)
    @category_types.each_with_object({}) do |ct, map|
      map[ct.id] = select_by_category_type(items, ct).group_by(&:category_id)
      map[ct.id].keys.each do |c_id|
        map[ct.id][c_id] = map[ct.id][c_id].index_by(&:state).transform_values(&:count)
      end
    end
  end

  def make_state_count(items)
    @category_types.each_with_object({}) do |ct, map|
      map[ct.id] = select_by_category_type(items, ct).group_by(&:state)
      map[ct.id].keys.each do |state|
        map[ct.id][state] = map[ct.id][state].index_by(&:category_id).transform_values(&:count)
      end
    end
  end

  def total_by_category
    @category_types.each_with_object({}) do |ct, total|
      total[ct.id] = {}
      @category_map[ct.id].each do |c|
        total[ct.id][c.id] = @category_count[ct.id][c.id].values.sum if @category_count[ct.id][c.id]
      end
    end
  end

  def total_by_state
    @category_types.each_with_object({}) do |ct, total|
      total[ct.id] = {}
      @state_options.each do |text, state|
        total[ct.id][state] = @state_count[ct.id][state].values.sum if @state_count[ct.id][state]
      end
    end
  end
end
