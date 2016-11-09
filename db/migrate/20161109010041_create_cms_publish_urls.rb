class CreateCmsPublishUrls < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_publish_urls do |t|
      t.string :name
      t.integer :publishable_id
      t.string :publishable_type
      t.integer :content_id
      t.integer :node_id
      t.timestamps
    end
  end
end
