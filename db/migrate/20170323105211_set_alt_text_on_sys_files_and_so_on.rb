class SetAltTextOnSysFilesAndSoOn < ActiveRecord::Migration[5.0]
  def change
    [:sys_files, :cms_data_files, :ad_banner_banners].each do |table|
      execute "update #{table} set alt_text = title"
    end
  end
end
