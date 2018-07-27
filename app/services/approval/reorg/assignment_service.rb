class Approval::Reorg::AssignmentService < ReorgService
  def initialize
    @model = Approval::Assignment
  end

  def reorganize_group(group_map)
    make_group_id_map(group_map, column: :group_id).tap do |id_map|
      update_group(id_map, column: :group_id)
      group_map.each do |src, dst|
        destroy_duplicated_group(dst)
      end
    end
  end

  def reorganize_user(user_map)
    make_user_id_map(user_map, column: :user_id).tap do |id_map|
      update_user(id_map, column: :user_id)
      user_map.each do |src, dst|
        destroy_duplicated_user(dst)
      end
    end
  end

  private

  def destroy_duplicated_group(group)
    types = @model.where(group_id: group.id, assign_type: 'group_users')
                  .order(:assignable_id, :assignable_type)
                  .group(:assignable_id, :assignable_type)
                  .pluck(:assignable_id, :assignable_type)

    types.each do |p_id, p_type|
      assigns = @model.where(assignable_id: p_id, assignable_type: p_type).order(:id)
      destroy_duplidated_group_assigns(group, assigns)
    end
  end

  def destroy_duplidated_group_assigns(group, assigns)
    or_map = assigns.group_by { |a| [a.or_group_id, a.selected_index] }
    or_map.each do |_, ass|
      items = ass.select { |a| a.group_id == group.id }
      items[1..-1].each(&:destroy) if items.size > 1
    end
  end

  def make_user_id_map(user_map, column: :user_id)
    user_map.each_with_object({}) do |(src, dst), id_map|
      ids = @model.where(column => src.id, approved_at: nil).order(:id).pluck(:id)
      id_map[[src, dst]] = ids if ids.present?
    end
  end

  def destroy_duplicated_user(user)
    types = @model.where(user_id: user.id, assign_type: 'user')
                  .order(:assignable_id, :assignable_type)
                  .group(:assignable_id, :assignable_type)
                  .pluck(:assignable_id, :assignable_type)

    types.each do |p_id, p_type|
      assigns = @model.where(assignable_id: p_id, assignable_type: p_type).order(:id)
      destroy_duplidated_user_assigns(user, assigns)
    end
  end

  def destroy_duplidated_user_assigns(user, assigns)
    or_map = assigns.group_by { |a| [a.or_group_id, a.selected_index] }
    or_map.each do |_, ass|
      items = ass.select { |a| a.user_id == user.id }
      items[1..-1].each(&:destroy) if items.size > 1
    end
  end
end
