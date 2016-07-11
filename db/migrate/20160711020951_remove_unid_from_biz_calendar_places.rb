class RemoveUnidFromBizCalendarPlaces < ActiveRecord::Migration
  def change
    remove_column :biz_calendar_places, :unid, :integer
  end
end
