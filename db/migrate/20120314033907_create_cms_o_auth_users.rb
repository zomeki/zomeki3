class CreateCmsOAuthUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :cms_o_auth_users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :image

      t.timestamps
    end
  end
end
