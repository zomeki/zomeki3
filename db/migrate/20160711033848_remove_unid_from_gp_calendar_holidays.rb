class RemoveUnidFromGpCalendarHolidays < ActiveRecord::Migration[4.2]
  def change
    remove_column :gp_calendar_holidays, :unid, :integer
  end
end
