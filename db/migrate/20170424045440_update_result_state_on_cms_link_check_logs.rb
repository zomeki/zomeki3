class UpdateResultStateOnCmsLinkCheckLogs < ActiveRecord::Migration[5.0]
  def up
    execute "update cms_link_check_logs set result_state = 'success' where result = true"
    execute "update cms_link_check_logs set result_state = 'failure' where result = false"
    execute "update cms_link_check_logs set checked_at = updated_at"
  end
  def down
  end
end
