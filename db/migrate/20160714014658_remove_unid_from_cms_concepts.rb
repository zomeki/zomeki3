class RemoveUnidFromCmsConcepts < ActiveRecord::Migration
  def change
    remove_column :cms_concepts, :unid, :integer
  end
end
