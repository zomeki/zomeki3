class AddNofollowAndLazyloadToAdBannerBanners < ActiveRecord::Migration[5.0]
  def up
    add_column :ad_banner_banners, :nofollow, :string
    add_column :ad_banner_banners, :lazyload, :string
  end
  
  def down
    remove_column :ad_banner_banners, :nofollow
    remove_column :ad_banner_banners, :lazyload
  end
end
