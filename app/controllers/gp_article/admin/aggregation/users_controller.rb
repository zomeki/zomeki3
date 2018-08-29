class GpArticle::Admin::Aggregation::UsersController < Cms::Controller::Admin::Base
  def pre_dispatch
    @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @group = Core.site.groups.find(params[:aggregation_group_id])
    return error_auth if !Core.user.has_auth?(:manager) && Core.user.group != @group
  end

  def index
    @users = @group.users.where(state: 'enabled')
    @state_options = GpArticle::Doc.state_options(except: 'archived')

    docs = GpArticle::Doc.arel_table
    creators = Sys::Creator.arel_table
    items = @content.docs.joins(:creator)
                    .select(docs[:state], creators[:user_id], docs[:state].count.as('count'))
                    .where(creators[:user_id].in(@users.map(&:id)))
                    .group(docs[:state], creators[:user_id])

    @user_count = make_user_count(items)
    @state_count = make_state_count(items)

    @user_total = total_by_user
    @state_total = total_by_state
  end

  private

  def make_user_count(items)
    map = items.group_by(&:user_id)
    map.keys.each do |user_id|
      map[user_id] = map[user_id].index_by(&:state).transform_values(&:count)
    end
    map
  end

  def make_state_count(items)
    map = items.group_by(&:state)
    map.keys.each do |state|
      map[state] = map[state].index_by(&:user_id).transform_values(&:count)
    end
    map
  end

  def total_by_user
    @users.each_with_object({}) do |user, total|
      total[user.id] = @user_count[user.id].values.sum if @user_count[user.id]
    end
  end

  def total_by_state
    @state_options.each_with_object({}) do |(text, state), total|
      total[state] = @state_count[state].values.sum if @state_count[state]
    end
  end
end
