class AddEtceteraToCmsPieces < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_pieces, :etcetera, :text
  end
end
