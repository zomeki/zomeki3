class RemoveUnidFromBizCalendarBussinessHours < ActiveRecord::Migration
  def change
    remove_column :biz_calendar_bussiness_hours, :unid, :integer
  end
end
