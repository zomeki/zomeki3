class ModifyDependentOfSysPublishersForCmsPages < ActiveRecord::Migration[5.0]
  def up
    execute "delete from sys_publishers where publishable_type = 'Cms::Node' and publishable_id in (select id from cms_nodes where model in ('Cms::Page', 'Cms::Sitemap')) and dependent = '_smart_phone'"
    execute "update sys_publishers set dependent = 'smart_phone' where dependent = '_smart_phone'"
    execute "update sys_publishers set dependent = 'ruby' where dependent = '/ruby'"
    execute "update sys_publishers set dependent = 'talk' where dependent = '/talk'"
  end

  def down
  end
end
