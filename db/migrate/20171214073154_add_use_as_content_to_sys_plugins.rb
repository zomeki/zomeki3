class AddUseAsContentToSysPlugins < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_plugins, :use_as_content, :boolean, default: false
  end
end
