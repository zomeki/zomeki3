class RemoveUnidFromCmsConcepts < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_concepts, :unid, :integer
  end
end
