class AddExtractedTextToSysFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_files, :extracted_text, :text
  end
end
