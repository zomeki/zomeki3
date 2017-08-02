class AddMobileFeatureToCmsSites < ActiveRecord::Migration[5.0]
  def change
    add_column :cms_sites, :mobile_feature, :string
  end
end
