class AddTalkProcessableToCmsTalkTasks < ActiveRecord::Migration
  def up
    add_column :cms_talk_tasks, :talk_processable_type, :string
    add_column :cms_talk_tasks, :talk_processable_id, :integer
    add_index :cms_talk_tasks, [:talk_processable_type, :talk_processable_id], name: 'index_cms_talk_tasks_on_talk_processable'
  end

  def down
    remove_index :cms_talk_tasks, name: 'index_cms_talk_tasks_on_talk_processable'
    remove_column :cms_talk_tasks, :talk_processable_id
    remove_column :cms_talk_tasks, :talk_processable_type
  end
end
