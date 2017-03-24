class AddAltTextToSysFilesAndSoOn < ActiveRecord::Migration[5.0]
  def change
    [:sys_files, :cms_data_files, :ad_banner_banners].each do |table|
      add_column table, :alt_text, :text
    end
  end
end
