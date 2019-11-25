class UpdateRequiredOnGpTemplateItems < ActiveRecord::Migration[5.0]
  def up
    execute "update gp_template_items set required = 'f'"
  end

  def down
  end
end
