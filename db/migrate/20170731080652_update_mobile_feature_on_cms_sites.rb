class UpdateMobileFeatureOnCmsSites < ActiveRecord::Migration[5.0]
  def up
    execute "update cms_sites set mobile_feature = 'enabled'"
  end

  def down
  end
end
