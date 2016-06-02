class AddEtceteraToCmsPieces < ActiveRecord::Migration
  def change
    add_column :cms_pieces, :etcetera, :text
  end
end
