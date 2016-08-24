class SetSiteIdToSysFilesAdBannerBanners < ActiveRecord::Migration
  def up
    Sys::File.where(tmp_id: nil).each do |item|
      if item.file_attachable && item.file_attachable.content
        item.update_columns(site_id: item.file_attachable.content.site_id)
      end
    end
    AdBanner::Banner.all.each do |item|
      item.update_columns(site_id: item.content.site_id) if item.content
    end
  end
  def down
  end
end
