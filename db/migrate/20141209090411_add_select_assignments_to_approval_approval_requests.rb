class AddSelectAssignmentsToApprovalApprovalRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :approval_approval_requests, :select_assignments, :text
  end
end
