class CreateSysReorgSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :sys_reorg_schedules do |t|
      t.references :site
      t.string     :state
      t.datetime   :reserved_at
      t.timestamps
    end
  end
end
