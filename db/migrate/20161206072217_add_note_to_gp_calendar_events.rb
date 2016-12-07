class AddNoteToGpCalendarEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :gp_calendar_events , :note, :text
  end
end
