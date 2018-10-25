class RemoveUnidFromGpCalendarEvents < ActiveRecord::Migration[4.2]
  def change
    remove_column :gp_calendar_events, :unid, :integer
  end
end
