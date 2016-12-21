class CreateSysStorageFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :sys_storage_files do |t|
      t.timestamps

      t.string :path, null: false
      t.boolean :available, null: false, default: true

      t.index :path, unique: true
    end
  end
end
