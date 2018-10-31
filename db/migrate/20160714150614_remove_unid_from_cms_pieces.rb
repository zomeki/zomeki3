class RemoveUnidFromCmsPieces < ActiveRecord::Migration[4.2]
  def change
    remove_column :cms_pieces, :unid, :integer
  end
end
