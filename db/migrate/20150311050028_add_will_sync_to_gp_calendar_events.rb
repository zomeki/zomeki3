class AddWillSyncToGpCalendarEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_calendar_events, :will_sync, :string
  end
end
