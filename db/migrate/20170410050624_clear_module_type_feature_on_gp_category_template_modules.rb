class ClearModuleTypeFeatureOnGpCategoryTemplateModules < ActiveRecord::Migration[5.0]
  def up
    execute "update gp_category_template_modules set module_type_feature = null"
  end
  def down
  end
end
