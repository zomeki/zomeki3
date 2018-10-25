class AddTelAttendToSysGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_groups, :tel_attend, :string
  end
end
