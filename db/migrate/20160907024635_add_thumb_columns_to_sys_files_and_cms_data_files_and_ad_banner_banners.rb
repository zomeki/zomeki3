class AddThumbColumnsToSysFilesAndCmsDataFilesAndAdBannerBanners < ActiveRecord::Migration
  def change
    [:sys_files, :cms_data_files, :ad_banner_banners].each do |table|
      add_column table, :thumb_width, :integer
      add_column table, :thumb_height, :integer
      add_column table, :thumb_size, :integer
    end
  end
end
