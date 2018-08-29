class GpArticle::Admin::Aggregation::GroupsController < Cms::Controller::Admin::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @groups = Core.site.groups.where(state: 'enabled').to_tree.flat_map(&:descendants).reject(&:root?)
    @state_options = GpArticle::Doc.state_options(except: 'archived')

    docs = GpArticle::Doc.arel_table
    creators = Sys::Creator.arel_table
    items = @content.docs.joins(:creator)
                    .select(docs[:state], creators[:group_id], docs[:state].count.as('count'))
                    .group(docs[:state], creators[:group_id])

    @group_count = make_group_count(items)
    @state_count = make_state_count(items)

    @group_total = total_by_group
    @state_total = total_by_state
  end

  private

  def make_group_count(items)
    map = items.group_by(&:group_id)
    map.keys.each do |group_id|
      map[group_id] = map[group_id].index_by(&:state).transform_values(&:count)
    end
    map
  end

  def make_state_count(items)
    map = items.group_by(&:state)
    map.keys.each do |state|
      map[state] = map[state].index_by(&:group_id).transform_values(&:count)
    end
    map
  end

  def total_by_group
    @groups.each_with_object({}) do |group, total|
      total[group.id] = @group_count[group.id].values.sum if @group_count[group.id]
    end
  end

  def total_by_state
    @state_options.each_with_object({}) do |(text, state), total|
      total[state] = @state_count[state].values.sum if @state_count[state]
    end
  end
end
