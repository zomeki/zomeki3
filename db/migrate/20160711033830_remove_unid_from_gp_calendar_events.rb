class RemoveUnidFromGpCalendarEvents < ActiveRecord::Migration
  def change
    remove_column :gp_calendar_events, :unid, :integer
  end
end
