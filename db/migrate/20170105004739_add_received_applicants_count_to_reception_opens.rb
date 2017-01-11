class AddReceivedApplicantsCountToReceptionOpens < ActiveRecord::Migration[5.0]
  def change
    add_column :reception_opens, :received_applicants_count, :integer, null: false, default: 0
  end
end
