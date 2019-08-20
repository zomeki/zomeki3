class DeleteEventImagesOnGpCalendarEvents < ActiveRecord::Migration[5.0]
  def up
    GpCalendar::Event.all.each do |event|
      next if event.files.size <= 1
      event.files.each_with_index {|file, i| file.destroy if i > 0}
    end
  end

  def down
  end
end
