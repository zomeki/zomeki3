class CreateCmsStylesheets < ActiveRecord::Migration[4.2]
  def change
    create_table :cms_stylesheets do |t|
      t.references :concept, index: true
      t.references :site, index: true
      t.timestamps
      t.string     :path
    end
  end
end
