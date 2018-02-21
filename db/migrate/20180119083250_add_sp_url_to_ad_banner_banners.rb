class AddSpUrlToAdBannerBanners < ActiveRecord::Migration[5.0]
  def change
    add_column :ad_banner_banners, :sp_url, :string
  end
end
