class AddSyncExportedToGpCalendarEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_calendar_events, :sync_exported, :string
  end
end
