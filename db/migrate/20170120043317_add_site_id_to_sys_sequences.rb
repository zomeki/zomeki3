class AddSiteIdToSysSequences < ActiveRecord::Migration[5.0]
  def up
    add_column :sys_sequences, :site_id, :integer
    remove_index :sys_sequences, [:name, :version]
    add_index :sys_sequences, [:site_id, :name, :version], unique: true, using: :btree
  end
end
