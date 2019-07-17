class AddNofollowAndLazyloadToAdBannerBanners < ActiveRecord::Migration[5.0]
  def change
    add_column :ad_banner_banners, :nofollow, :string
    add_column :ad_banner_banners, :lazyload, :string
  end
end
