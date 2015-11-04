class AddIndexOnStateAndParentIdAndSoOnToCmsNodes < ActiveRecord::Migration
  def change
    add_index :cms_nodes, :state
    add_index :cms_nodes, :site_id
    add_index :cms_nodes, :parent_id
    add_index :cms_nodes, :route_id
    add_index :cms_nodes, :content_id
    add_index :cms_nodes, :layout_id
    add_index :cms_nodes, :concept_id
  end
end
