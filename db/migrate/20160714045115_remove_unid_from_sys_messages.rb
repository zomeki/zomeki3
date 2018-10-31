class RemoveUnidFromSysMessages < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_messages, :unid, :integer
  end
end
