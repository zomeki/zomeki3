class AddColumnRepeatToGpCalendarHolidays < ActiveRecord::Migration[4.2]
  def change
    add_column :gp_calendar_holidays, :repeat, :boolean
  end
end
