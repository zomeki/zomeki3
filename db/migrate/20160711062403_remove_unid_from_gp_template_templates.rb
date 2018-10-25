class RemoveUnidFromGpTemplateTemplates < ActiveRecord::Migration[4.2]
  def change
    remove_column :gp_template_templates, :unid, :integer
  end
end
