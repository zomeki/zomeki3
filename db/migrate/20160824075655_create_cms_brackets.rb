class CreateCmsBrackets < ActiveRecord::Migration
  def change
    create_table :cms_brackets do |t|
      t.references :site, index: true
      t.references :concept, index: true
      t.references :owner, index: true, polymorphic: true
      t.string     :name, index: true
      t.timestamps
    end
  end
end
