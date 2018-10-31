class ChangeSyncSourceIdOnGpCalendarEvents < ActiveRecord::Migration[4.2]
  def up
    change_column :gp_calendar_events, :sync_source_id, :string
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
