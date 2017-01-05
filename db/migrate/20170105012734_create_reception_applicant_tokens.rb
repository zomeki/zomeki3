class CreateReceptionApplicantTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :reception_applicant_tokens do |t|
      t.references  :open, index: true
      t.references  :applicant, index: true
      t.integer     :seq_no
      t.string      :state
      t.string      :token
      t.timestamps
    end
  end
end
