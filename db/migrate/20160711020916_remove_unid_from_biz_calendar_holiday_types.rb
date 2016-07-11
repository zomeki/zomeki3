class RemoveUnidFromBizCalendarHolidayTypes < ActiveRecord::Migration
  def change
    remove_column :biz_calendar_holiday_types, :unid, :integer
  end
end
