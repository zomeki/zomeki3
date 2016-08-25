class CreateCmsNodePublishers < ActiveRecord::Migration
  def change
    create_table :cms_node_publishers do |t|
      t.integer :node_id, index: true
      t.timestamps
    end
  end
end
