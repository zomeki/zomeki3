class AddSiteIdToCmsLinkCheckLogs < ActiveRecord::Migration[5.0]
  def change
    add_column :cms_link_check_logs, :site_id, :integer
  end
end
