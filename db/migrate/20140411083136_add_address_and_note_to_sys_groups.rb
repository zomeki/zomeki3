class AddAddressAndNoteToSysGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_groups, :address, :string
    add_column :sys_groups, :note, :string
  end
end
