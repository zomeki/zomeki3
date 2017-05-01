class AddResultStateAndCheckedAtToCmsLinkCheckLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :cms_link_check_logs, :result_state, :string
    add_column :cms_link_check_logs, :checked_at, :datetime
    add_index :cms_link_check_logs, [:link_checkable_id, :link_checkable_type], name: 'index_cms_link_check_logs_on_link_checkable_id_and_type'
    add_index :cms_link_check_logs, :result_state
  end
end
