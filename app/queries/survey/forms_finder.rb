class Survey::FormsFinder < FinderQuery
  def initialize(forms, user)
    @forms = forms
    @user = user
  end

  def search(criteria)
    @forms = with_target(criteria[:target]) if criteria[:target].present?
    @forms = with_target_state(criteria[:target_state]) if criteria[:target_state].present?
    @forms
  end

  private

  def arel_table
    @forms.arel_table
  end

  def with_target(target)
    case target
    when 'user'
      @forms.creator_or_approvables
    when 'group'
      creators = Sys::Creator.arel_table
      @forms.joins(:creator)
            .where(creators[:group_id].in(@user.groups.map(&:id)))
    when 'all'
      @forms.all
    else
      @forms.none
    end
  end

  def with_target_state(target_state)
    case target_state
    when 'processing'
      @forms.where(state: %w(draft approvable approved prepared))
    when 'public'
      @forms.where(state: 'public')
    when 'closed'
      @forms.where(state: 'closed')
    when 'all'
      @forms.all
    else
      @forms.none
    end
  end
end
