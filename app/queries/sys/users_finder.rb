class Sys::UsersFinder < FinderQuery
  def initialize(users)
    @users = users
  end

  def search(criteria)
    [:account, :name, :email].each do |key|
      @users = @users.search_with_text(key, criteria[key]) if criteria[key].present?
    end

    [:state, :auth_no].each do |key|
      @users = @users.where(key => criteria[key]) if criteria[key].present?
    end

    if criteria[:group_id].present?
      gid = criteria[:group_id] == 'no_group' ? nil : criteria[:group_id]
      @users = @users.joins(:groups).where(sys_groups: { id: gid })
    end

    @users
  end

  private

  def arel_table
    @users.arel_table
  end
end
