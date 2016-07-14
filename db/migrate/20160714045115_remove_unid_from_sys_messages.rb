class RemoveUnidFromSysMessages < ActiveRecord::Migration
  def change
    remove_column :sys_messages, :unid, :integer
  end
end
