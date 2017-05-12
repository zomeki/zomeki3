class AddStateToSysTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :sys_tasks, :state, :string
    add_column :sys_tasks, :job_id, :string
    add_column :sys_tasks, :provider_job_id, :integer
    add_index :sys_tasks, :site_id
    add_index :sys_tasks, :state
  end
end
