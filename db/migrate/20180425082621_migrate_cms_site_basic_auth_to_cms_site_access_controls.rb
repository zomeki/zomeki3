class MigrateCmsSiteBasicAuthToCmsSiteAccessControls < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      insert into cms_site_access_controls (id, site_id, state, target_type, target_location, basic_auth, created_at, updated_at)
        select id, site_id, state, target_type, target_location, concat(name, ', ', password), created_at, updated_at from cms_site_basic_auth_users order by id;
      select setval('cms_site_access_controls_id_seq', (select max(id) from cms_site_access_controls));
    SQL
    execute <<-SQL
      update cms_site_settings set name = 'access_control_state' where name = 'basic_auth_state';
      update sys_creators set creatable_type = 'Cms::SiteAccessControl' where creatable_type = 'Cms::SiteBasicAuthUser';
    SQL
  end

  def down
  end
end
