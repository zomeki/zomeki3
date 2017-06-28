class CreateCmsImportation < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_importations do |t|
      t.belongs_to :importable, polymorphic: true, index: true
      t.string     :source_url
      t.timestamps
    end
  end
end
