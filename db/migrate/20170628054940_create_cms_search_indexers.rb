class CreateCmsSearchIndexers < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_search_indexers do |t|
      t.references :site, index: true
      t.references :indexable, polymorphic: true, index: true
      t.string     :state
      t.integer    :priority
      t.timestamps
    end
  end
end
