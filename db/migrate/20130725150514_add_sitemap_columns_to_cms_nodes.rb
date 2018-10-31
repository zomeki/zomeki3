class AddSitemapColumnsToCmsNodes < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_nodes, :sitemap_state, :string
    add_column :cms_nodes, :sitemap_sort_no, :integer
  end
end
