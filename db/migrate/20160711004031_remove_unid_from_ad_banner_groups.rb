class RemoveUnidFromAdBannerGroups < ActiveRecord::Migration
  def change
    remove_column :ad_banner_groups, :unid, :integer
  end
end
