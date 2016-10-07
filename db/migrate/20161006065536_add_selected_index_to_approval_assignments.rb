class AddSelectedIndexToApprovalAssignments < ActiveRecord::Migration
  def change
    add_column :approval_assignments, :selected_index, :integer
    add_index :approval_assignments, :selected_index
  end
end
