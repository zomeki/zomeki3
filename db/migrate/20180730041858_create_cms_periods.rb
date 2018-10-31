class CreateCmsPeriods < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_periods do |t|
      t.references :periodable, polymorphic: true
      t.date       :started_on
      t.date       :ended_on
      t.timestamps
    end
  end
end
