class RemoveUnidFromCmsPieces < ActiveRecord::Migration
  def change
    remove_column :cms_pieces, :unid, :integer
  end
end
