class AddRequiredToGpTemplateItems < ActiveRecord::Migration[5.0]
  def up
    add_column :gp_template_items, :required, :boolean, :default => true
  end
  
  def down
    remove_column :gp_template_items, :required
  end
end
