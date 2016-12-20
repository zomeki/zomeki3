class AddMimeTypeAndExtractedTextToSysStorageFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_storage_files, :mime_type, :string
    add_column :sys_storage_files, :extracted_text, :text
  end
end
