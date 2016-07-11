class RemoveUnidFromAdBannerBanners < ActiveRecord::Migration
  def change
    remove_column :ad_banner_banners, :unid, :integer
  end
end
