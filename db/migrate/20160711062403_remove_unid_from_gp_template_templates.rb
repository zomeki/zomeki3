class RemoveUnidFromGpTemplateTemplates < ActiveRecord::Migration
  def change
    remove_column :gp_template_templates, :unid, :integer
  end
end
