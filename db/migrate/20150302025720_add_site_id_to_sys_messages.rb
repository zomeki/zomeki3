class AddSiteIdToSysMessages < ActiveRecord::Migration
  def up
    add_column :sys_messages, :site_id, :integer

    if site_id = Cms::Site.first.try!(:id)
      Sys::Message.find_each do |message|
        message.update_column(:site_id, site_id) unless message.site_id
      end
    end
  end

  def down
    remove_column :sys_messages, :site_id
  end
end
