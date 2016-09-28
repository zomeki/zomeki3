class AddSiteIdToSysTasks < ActiveRecord::Migration
  def change
    add_column :sys_tasks, :site_id, :integer
    add_column :cms_talk_tasks, :site_id, :integer
  end
end
