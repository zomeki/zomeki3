class AddSiteIdToSysFilesAdBannerBanners < ActiveRecord::Migration[4.2]
  def change
    add_column :sys_files, :site_id, :integer
    add_column :ad_banner_banners, :site_id, :integer
  end
end
