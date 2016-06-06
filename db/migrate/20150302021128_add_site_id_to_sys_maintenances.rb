class AddSiteIdToSysMaintenances < ActiveRecord::Migration
  def up
    add_column :sys_maintenances, :site_id, :integer

    if site_id = Cms::Site.first.try!(:id)
      Sys::Maintenance.find_each do |maintenance|
        maintenance.update_column(:site_id, site_id) unless maintenance.site_id
      end
    end
  end

  def down
    remove_column :sys_maintenances, :site_id
  end
end
