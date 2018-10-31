class RemoveSyncExportedFromCalendarEvents < ActiveRecord::Migration[4.2]
  def up
    remove_column :gp_calendar_events, :sync_exported
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
