class RemoveUnidFromBizCalendarExceptionHolidays < ActiveRecord::Migration[4.2]
  def change
    remove_column :biz_calendar_exception_holidays, :unid, :integer
  end
end
