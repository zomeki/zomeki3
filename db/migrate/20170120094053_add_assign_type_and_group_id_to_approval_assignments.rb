class AddAssignTypeAndGroupIdToApprovalAssignments < ActiveRecord::Migration[5.0]
  def change
    add_column :approval_assignments, :group_id, :integer
    add_column :approval_assignments, :assign_type, :string
  end
end
