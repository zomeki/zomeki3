class AddApprovalTypeToApprovalApprovals < ActiveRecord::Migration[4.2]
  def change
    add_column :approval_approvals, :approval_type, :text
    Approval::Approval.update_all(approval_type: 'fix')
  end
end
