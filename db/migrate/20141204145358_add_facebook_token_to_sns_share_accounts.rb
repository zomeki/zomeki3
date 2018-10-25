class AddFacebookTokenToSnsShareAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :sns_share_accounts, :facebook_token_options, :text
    add_column :sns_share_accounts, :facebook_token, :string
  end
end
