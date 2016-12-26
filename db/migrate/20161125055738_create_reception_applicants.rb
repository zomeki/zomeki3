class CreateReceptionApplicants < ActiveRecord::Migration[5.0]
  def change
    create_table :reception_applicants do |t|
      t.references  :open, index: true
      t.integer     :seq_no
      t.string      :state
      t.string      :name
      t.string      :kana
      t.string      :tel
      t.string      :email
      t.text        :remark
      t.string      :applied_from
      t.datetime    :applied_at
      t.string      :token
      t.timestamps
    end
  end
end
