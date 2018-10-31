class RemoveUnidFromAdBannerBanners < ActiveRecord::Migration[4.2]
  def change
    remove_column :ad_banner_banners, :unid, :integer
  end
end
