class AddRepeatCriterionToBizCalendarBussinessHolidays < ActiveRecord::Migration[4.2]
  def change
    add_column :biz_calendar_bussiness_holidays, :repeat_criterion, :text
  end
end
