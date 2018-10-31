class AddSiteIdToSysTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_tasks, :site_id, :integer
    add_column :cms_talk_tasks, :site_id, :integer
  end
end
