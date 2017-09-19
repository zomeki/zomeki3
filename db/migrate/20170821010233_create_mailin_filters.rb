class CreateMailinFilters < ActiveRecord::Migration[5.0]
  def change
    create_table :mailin_filters do |t|
      t.references  :content, index: true
      t.string      :state
      t.string      :to
      t.string      :subject
      t.references  :dest_content, index: true
      t.integer     :sort_no
      t.datetime    :filtered_at
      t.timestamps
    end
  end
end
