class CreateApprovalApprovalRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :approval_approval_requests do |t|
      t.belongs_to :user
      t.belongs_to :approval_flow
      t.belongs_to :approvable, polymorphic: true
      t.integer    :current_index

      t.timestamps
    end
  end
end
