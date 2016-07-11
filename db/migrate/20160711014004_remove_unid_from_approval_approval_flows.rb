class RemoveUnidFromApprovalApprovalFlows < ActiveRecord::Migration
  def change
    remove_column :approval_approval_flows, :unid, :integer
  end
end
