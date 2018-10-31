class AddEndTypeAndEndTimesToBizCalendarBussinessHolidays < ActiveRecord::Migration[4.2]
  def change
    add_column :biz_calendar_bussiness_holidays, :end_type, :integer
    add_column :biz_calendar_bussiness_holidays, :end_times, :integer
  end
end
