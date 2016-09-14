class CreateCmsStylesheets < ActiveRecord::Migration
  def change
    create_table :cms_stylesheets do |t|
      t.references :concept, index: true
      t.references :site, index: true
      t.timestamps
      t.string     :path
    end
  end
end
