class UpdateBaseUrlOnSysPlugins < ActiveRecord::Migration[5.0]
  def up
    execute "update sys_plugins set base_url = 'https://github.com/'"
  end

  def down
  end
end
