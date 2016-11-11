class AddExtractedTextToCmsDataFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :cms_data_files, :extracted_text, :text
  end
end
