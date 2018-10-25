class AddSppTargetToCmsSites < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_sites, :spp_target, :string
  end
end
