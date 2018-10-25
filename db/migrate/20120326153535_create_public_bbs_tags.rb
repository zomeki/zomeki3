class CreatePublicBbsTags < ActiveRecord::Migration[4.2]
  def change
    create_table :public_bbs_tags, :force => true do |t|
      t.integer :unid

      t.string :name
      t.text :word

      t.timestamps
    end
  end
end
