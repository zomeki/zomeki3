class AddExtraValueToCmsContentSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_content_settings, :extra_value, :text
  end
end
