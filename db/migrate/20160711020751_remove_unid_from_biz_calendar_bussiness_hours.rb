class RemoveUnidFromBizCalendarBussinessHours < ActiveRecord::Migration[4.2]
  def change
    remove_column :biz_calendar_bussiness_hours, :unid, :integer
  end
end
