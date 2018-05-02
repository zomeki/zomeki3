class GpArticle::DocsFinder < ApplicationFinder
  def initialize(docs, user)
    @docs = docs
    @user = user
  end

  def search(criteria)
    @docs = with_target(criteria[:target]) if criteria[:target].present?
    @docs = with_target_state(criteria[:target_state]) if criteria[:target_state].present?

    [:state, :event_state, :marker_state].each do |key|
      @docs = @docs.where(key => criteria[key]) if criteria[key].present?
    end

    if criteria[:creator_user_name].present?
      @docs = operated_by_user_name('create', criteria[:creator_user_name])
    end

    if criteria[:creator_group_id].present?
      @docs = operated_by_group('create', criteria[:creator_group_id])
    end

    if criteria[:category_ids].present? && (category_ids = criteria[:category_ids].select(&:present?)).present?
      @docs = @docs.categorized_into(category_ids, alls: true)
    end

    if criteria[:user_operation].present?
      @docs = operated_by_user_name(criteria[:user_operation], criteria[:user_name]) if criteria[:user_name].present?
      @docs = operated_by_group(criteria[:user_operation], criteria[:user_group_id]) if criteria[:user_group_id].present?
    end

    if criteria[:date_column].present? && criteria[:date_operation].present?
      dates = criteria[:dates].to_a.map { |date| date.present? ? (Date.parse(date) rescue nil) : nil }.compact
      @docs = search_date_column(criteria[:date_column], criteria[:date_operation], dates)
    end

    if criteria[:assocs].present?
      criteria[:assocs].select(&:present?).each { |assoc| @docs = @docs.joins(assoc.to_sym) }
    end

    if criteria[:tasks].present?
      criteria[:tasks].select(&:present?).each { |task| @docs = @docs.with_task_name(task) }
    end

    if criteria[:texts].present?
      criteria[:texts].select(&:present?).each do |column|
        @docs = @docs.where.not(arel_table[column].eq('')).where.not(arel_table[column].eq(nil))
      end
    end

    search_columns = [:name, :title, :body, :subtitle, :summary, :mobile_title, :mobile_body]
    @docs = @docs.search_with_logical_query(*search_columns, criteria[:free_word]) if criteria[:free_word].present?
    @docs = @docs.where(serial_no: criteria[:serial_no]) if criteria[:serial_no].present?

    if criteria[:sort_key].present?
      @docs = sort_by(criteria[:sort_key], criteria[:sort_order])
    end

    @docs
  end

  private

  def arel_table
    @docs.arel_table
  end

  def with_target(target)
    case target
    when 'user'
      @docs.creator_or_approvables(@user)
    when 'group'
      @docs.editable
    when 'all'
      @docs.all
    else
      @docs.none
    end
  end

  def with_target_state(target_state)
    case target_state
    when 'processing'
      @docs.where(state: %w(draft approvable approved prepared))
    when 'public'
      @docs.where(state: 'public')
    when 'closed'
      @docs.where(state: 'closed')
    when 'trashed'
      @docs.where(state: 'trashed')
    when 'all'
      @docs.all.where.not(state: 'trashed')
    else
      @docs.none
    end
  end

  def operated_by_user_name(action, user_name)
    case action
    when 'create'
      users = Sys::User.arel_table
      @docs.joins(creator: :user)
               .where([users[:name].matches("%#{user_name}%"),
                       users[:name_en].matches("%#{user_name}%")].reduce(:or))
    else
      operation_logs = Sys::OperationLog.arel_table
      users = Sys::User.arel_table
      @docs.joins(operation_logs: :user)
               .where(operation_logs[:action].eq(action))
               .where([users[:name].matches("%#{user_name}%"),
                       users[:name_en].matches("%#{user_name}%")].reduce(:or))
    end
  end

  def operated_by_group(action, group_id)
    case action
    when 'create'
      creators = Sys::Creator.arel_table
      @docs.joins(:creator)
               .where(creators[:group_id].eq(group_id))
    else
      operation_logs = Sys::OperationLog.arel_table
      users_groups = Sys::UsersGroup.arel_table
      @docs.joins(operation_logs: { user: :users_groups })
               .where(operation_logs[:action].eq(action))
               .where(users_groups[:group_id].eq(group_id))
    end
  end

  def search_date_column(column, operation, dates = nil)
    dates = Array.wrap(dates)
    case operation
    when 'today'
      today = Date.today
      @docs.date_between(column, today.beginning_of_day, today.end_of_day)
    when 'this_week'
      today = Date.today
      @docs.date_between(column, today.beginning_of_week, today.end_of_week)
    when 'last_week'
      last_week = 1.week.ago
      @docs.date_between(column, last_week.beginning_of_week, last_week.end_of_week)
    when 'equal'
      @docs.date_between(column, dates[0].beginning_of_day, dates[0].end_of_day) if dates[0]
    when 'before'
      @docs.date_before(column, dates[0].end_of_day) if dates[0]
    when 'after'
      @docs.date_after(column, dates[0].beginning_of_day) if dates[0]
    when 'between'
      @docs.date_between(column, dates[0].beginning_of_day, dates[1].end_of_day) if dates[0] && dates[1]
    else
      @docs.none
    end
  end

  def sort_by(key, order)
    order = (order.presence || :asc).to_sym

    if key.index('.')
      table, column = key.split('.')
      case table
      when 'sys_groups'
        @docs.eager_load(creator: :group).merge(Sys::Group.order(column => order))
      when 'sys_users'
        @docs.eager_load(creator: :user).merge(Sys::User.order(column => order))
      else
        @docs.none
      end
    else
      @docs.order(key => order)
    end
  end
end
