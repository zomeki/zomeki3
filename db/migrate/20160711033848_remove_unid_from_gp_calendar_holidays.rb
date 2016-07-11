class RemoveUnidFromGpCalendarHolidays < ActiveRecord::Migration
  def change
    remove_column :gp_calendar_holidays, :unid, :integer
  end
end
