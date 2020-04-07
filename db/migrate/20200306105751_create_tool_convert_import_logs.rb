class CreateToolConvertImportLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :tool_convert_import_logs do |t|
      t.references :convert_import
      t.text       :message
      t.timestamps
    end
  end
end
