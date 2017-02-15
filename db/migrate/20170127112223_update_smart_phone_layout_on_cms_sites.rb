class UpdateSmartPhoneLayoutOnCmsSites < ActiveRecord::Migration[5.0]
  def change
    execute "update cms_sites set smart_phone_layout = 'smart_phone'"
  end
end
