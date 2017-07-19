class AddCreatorGroupTagToToolConvertSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_convert_settings, :creator_group_tag, :text
    add_column :tool_convert_settings, :creator_group_regexp, :text
    add_column :tool_convert_settings, :category_relations, :text
    rename_column :tool_convert_settings, :creator_group_url_relations, :creator_group_relations
  end
end
