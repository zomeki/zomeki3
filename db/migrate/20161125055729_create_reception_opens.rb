class CreateReceptionOpens < ActiveRecord::Migration[5.0]
  def change
    create_table :reception_opens do |t|
      t.references  :course, index: true
      t.string      :state
      t.string      :title
      t.integer     :sort_no
      t.date        :open_on
      t.time        :start_at
      t.time        :end_at
      t.string      :place
      t.string      :lecturer
      t.datetime    :expired_at
      t.timestamps
    end
  end
end
