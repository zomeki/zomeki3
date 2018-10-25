class AddTargetToAdBannerBanners < ActiveRecord::Migration[4.2]
  def change
    add_column :ad_banner_banners, :target, :text
    AdBanner::Banner.update_all(target: '_blank')
  end
end
