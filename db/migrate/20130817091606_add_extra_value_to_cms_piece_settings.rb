class AddExtraValueToCmsPieceSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :cms_piece_settings, :extra_value, :text
  end
end
