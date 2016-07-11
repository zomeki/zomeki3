class RemoveUnidFromBizCalendarExceptionHolidays < ActiveRecord::Migration
  def change
    remove_column :biz_calendar_exception_holidays, :unid, :integer
  end
end
