class AddPublishedAtTagAndPublishedAtRegexpToToolConvertSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_convert_settings, :published_at_tag, :text
    add_column :tool_convert_settings, :published_at_regexp, :text
  end
end
