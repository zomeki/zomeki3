class AddBaseUrlToSysPlugins < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_plugins, :base_url, :string
  end
end
