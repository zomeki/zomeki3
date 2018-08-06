class CreateReorgTables < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_reorg_site_belongings do |t|
      t.references :site
      t.timestamps
      t.references :group
    end

    create_table :sys_reorg_groups do |t|
      t.string     :state
      t.string     :web_state
      t.timestamps
      t.references :parent
      t.integer    :level_no
      t.string     :code
      t.integer    :sort_no
      t.integer    :layout_id
      t.integer    :ldap
      t.string     :ldap_version
      t.string     :name
      t.string     :name_en
      t.string     :tel
      t.string     :outline_uri
      t.string     :email
      t.string     :fax
      t.string     :address
      t.string     :note
      t.string     :tel_attend
      t.references :sys_group
      t.string     :change_state
    end

    create_table :sys_reorg_users_groups do |t|
      t.timestamps
      t.references :user
      t.references :group
    end

    create_table :sys_reorg_users do |t|
      t.string     :state
      t.timestamps
      t.integer    :ldap
      t.string     :ldap_version
      t.integer    :auth_no
      t.string     :name
      t.string     :name_en
      t.string     :account
      t.string     :password
      t.string     :email
      t.text       :remember_token
      t.datetime   :remember_token_expires_at
      t.boolean    :admin_creatable, default: false
      t.boolean    :site_creatable, default: false
      t.string     :reset_password_token
      t.datetime   :reset_password_token_expires_at
      t.references :sys_user
      t.string     :change_state
    end

    create_table :sys_reorg_users_roles do |t|
      t.references :user
      t.references :role
      t.timestamps
    end

    create_table :sys_reorg_group_migrations do |t|
      t.timestamps
      t.references :group
      t.references :source_group
    end

    create_table :sys_reorg_user_migrations do |t|
      t.timestamps
      t.references :user
      t.references :source_user
    end
  end
end
