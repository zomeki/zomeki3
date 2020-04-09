class DeleteEventsOnGpCalendarEvents < ActiveRecord::Migration[5.0]
  def up
    GpCalendar::Event.all.each do |event|
      next if event.content.blank?
      event.destroy if event.periods.blank?
    end
  end

  def down
  end
end
