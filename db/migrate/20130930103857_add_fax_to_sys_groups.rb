class AddFaxToSysGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_groups, :fax, :string, :after => :tel
  end
end
