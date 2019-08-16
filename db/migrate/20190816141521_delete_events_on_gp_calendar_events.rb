class DeleteEventsOnGpCalendarEvents < ActiveRecord::Migration[5.0]
  def up
    GpCalendar::Event.all.each do |event|
      event.destroy if event.periods.blank?
    end
  end

  def down
  end
end
