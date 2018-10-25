class AddBodyToCmsSites < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_sites, :body, :text
  end
end
