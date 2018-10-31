class AddNameVersionIndexToSysSequences < ActiveRecord::Migration[4.2]
  def up
    remove_index :sys_sequences, [:name, :version]
    add_index :sys_sequences, [:name, :version], :unique => true
  end

  def down
    remove_index :sys_sequences, [:name, :version]
    add_index :sys_sequences, [:name, :version]
  end
end
