class RemoveUnidFromBizCalendarBussinessHolidays < ActiveRecord::Migration
  def change
    remove_column :biz_calendar_bussiness_holidays, :unid, :integer
  end
end
