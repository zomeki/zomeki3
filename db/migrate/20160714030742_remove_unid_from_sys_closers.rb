class RemoveUnidFromSysClosers < ActiveRecord::Migration[4.2]
  def change
    remove_column :sys_closers, :unid, :integer
  end
end
