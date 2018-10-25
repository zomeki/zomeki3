class AddSyncColumnsToGpCalendarHolidays < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_calendar_holidays, :sync_source_host, :string
    add_column :gp_calendar_holidays, :sync_source_content_id, :integer
    add_column :gp_calendar_holidays, :sync_source_id, :integer
  end
end
