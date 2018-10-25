class AddSelectedIndexToApprovalAssignments < ActiveRecord::Migration[4.2]
  def change
    add_column :approval_assignments, :selected_index, :integer
    add_index :approval_assignments, :selected_index
  end
end
