class RemoveUnidFromBizCalendarHolidayTypes < ActiveRecord::Migration[4.2]
  def change
    remove_column :biz_calendar_holiday_types, :unid, :integer
  end
end
