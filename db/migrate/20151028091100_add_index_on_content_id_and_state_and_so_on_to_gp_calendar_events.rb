class AddIndexOnContentIdAndStateAndSoOnToGpCalendarEvents < ActiveRecord::Migration
  def change
    add_index :gp_calendar_events, :content_id
    add_index :gp_calendar_events, :state
    add_index :gp_calendar_events, [:started_on, :ended_on]
  end
end
