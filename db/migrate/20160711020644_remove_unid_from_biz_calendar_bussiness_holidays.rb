class RemoveUnidFromBizCalendarBussinessHolidays < ActiveRecord::Migration[4.2]
  def change
    remove_column :biz_calendar_bussiness_holidays, :unid, :integer
  end
end
