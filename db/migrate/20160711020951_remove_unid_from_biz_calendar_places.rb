class RemoveUnidFromBizCalendarPlaces < ActiveRecord::Migration[4.2]
  def change
    remove_column :biz_calendar_places, :unid, :integer
  end
end
