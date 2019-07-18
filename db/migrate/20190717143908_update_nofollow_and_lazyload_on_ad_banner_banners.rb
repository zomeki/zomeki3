class UpdateNofollowAndLazyloadOnAdBannerBanners < ActiveRecord::Migration[5.0]
  def up
    execute "update ad_banner_banners set nofollow = 'enabled', lazyload = 'enabled'"
  end

  def down
  end
end
