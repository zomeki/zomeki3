class RemoveUniquenessFromTokenOnAdBannerBanners < ActiveRecord::Migration[5.0]
  def change
    remove_index :ad_banner_banners, :token
    add_index :ad_banner_banners, :token
  end
end
