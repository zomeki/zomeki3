class RemoveUnidFromApprovalApprovalFlows < ActiveRecord::Migration[4.2]
  def change
    remove_column :approval_approval_flows, :unid, :integer
  end
end
