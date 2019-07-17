class UpdateNofollowAndLazyloadOnAdBannerBanners < ActiveRecord::Migration[5.0]
  def change
    execute "update ad_banner_banners set nofollow = 'enabled', lazyload = 'enabled'"
  end
end
