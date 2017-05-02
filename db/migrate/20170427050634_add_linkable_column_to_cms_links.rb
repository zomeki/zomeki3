class AddLinkableColumnToCmsLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :cms_links, :linkable_column, :string
    add_index :cms_links, [:linkable_id, :linkable_type]
  end
end
