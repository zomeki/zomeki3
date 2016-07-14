class RemoveUnidFromSysClosers < ActiveRecord::Migration
  def change
    remove_column :sys_closers, :unid, :integer
  end
end
