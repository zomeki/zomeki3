class UpdateAssignTypeOnApprovalAssignments < ActiveRecord::Migration[5.0]
  def up
    execute "update approval_assignments set assign_type = 'user'"
  end
end
