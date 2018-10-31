class CreateAdBannerGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :ad_banner_groups do |t|
      t.integer    :unid
      t.references :content

      t.string  :state

      t.string  :name
      t.string  :title
      t.integer :sort_no

      t.timestamps
    end
  end
end
