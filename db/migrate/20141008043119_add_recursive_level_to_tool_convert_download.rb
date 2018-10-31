class AddRecursiveLevelToToolConvertDownload < ActiveRecord::Migration[4.2]
  def change
    add_column :tool_convert_downloads, :recursive_level, :integer, :after => :end_at
  end
end
