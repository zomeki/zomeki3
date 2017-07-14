class AddLogToToolConvertImports < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_convert_imports, :creator_group_id, :integer
    add_column :tool_convert_imports, :log, :text
  end
end
