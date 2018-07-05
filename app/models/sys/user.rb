class Sys::User < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Auth::Manager

  ROOT_ID = 1

  enum_ish :state, [:enabled, :disabled]
  enum_ish :auth_no, [2, 4, 5]
  enum_ish :ldap_state, [1, 0]
  enum_ish :admin_creatable, [true, false]

  has_many :users_groups, foreign_key: :user_id, dependent: :destroy
  has_many :groups, through: :users_groups, source: :group
  has_many :users_roles, foreign_key: :user_id, dependent: :destroy
  has_many :role_names, through: :users_roles, source: :role_name
  has_many :operation_logs
  has_many :users_holds, dependent: :delete_all
  has_many :users_sessions, dependent: :delete_all

  accepts_nested_attributes_for :users_groups

  validates :state, :name, :ldap, presence: true
  validates :account, presence: true,
                      format: { with: /\A[\x20-\x7F]*\z/ },
                      uniqueness: { if: :root? }

  validate :validate_auth_for_root
  validate :validate_account_uniqueness_in_site, if: -> { !root? && users_groups.present? }

  before_destroy :block_root_deletion

  nested_scope :in_site, through: :users_groups

  scope :in_group, ->(group) {
    klass = reflect_on_association(:users_groups).klass
    joins(:users_groups).where(klass.table_name.to_sym => { group_id: group })
  }

  def creatable?
    Core.user.has_auth?(:manager)
  end

  def readable?
    Core.user.root? ||
      (Core.user.has_auth?(:manager) && (sites & Core.user.sites).present?) ||
      (Core.user.id == id)
  end

  def editable?
    readable? && editable_user?
  end

  def deletable?
    readable? && deletable_user?
  end

  def editable_user?
    !root? || (root? && Core.user.root?)
  end

  def deletable_user?
    !root?
  end

  def name_with_id
    "#{name}（#{id}）"
  end

  def name_with_account
    "#{name}（#{account}）"
  end

  def group
    groups[0]
  end

  def group_id
    group ? group.id : nil
  end

  def has_auth?(name)
    auth = {
      none:     0, # なし  操作不可
      reader:   1, # 読者  閲覧のみ
      creator:  2, #作成者 記事作成者
      editor:   3, #編集者 データ作成者
      designer: 4, #設計者 デザイン作成者
      manager:  5, #管理者 設定作成者
    }
    raise "Unknown authority name: #{name}" unless auth.has_key?(name)
    return auth[name] <= auth_no
  end

  def has_priv?(action, options = {})
    return true if root?
    return true if has_auth?(:manager) &&
                   (options[:site_id].in?(site_ids) || (options[:item] && options[:item].site_id.in?(site_ids)))
    return false unless options[:item]

    role_ids = Sys::ObjectPrivilege.where(action: action.to_s, privilegable: options[:item]).pluck(:role_id)
    users_roles.where(role_id: role_ids).exists?
  end

  ## -----------------------------------
  ## Authenticates

  def self.login_users(account, site: nil)
    root_users = self.where(state: 'enabled', account: account, id: ROOT_ID)
    users = self.where(state: 'enabled', account: account)
    users = users.in_site(site) if site
    [root_users, users].reduce(:union)
  end

  ## Authenticates a user by their account name and unencrypted password.  Returns the user or nil.
  def self.authenticate(in_account, in_password, encrypted: false, site: nil)
    crypt_pass  = Zomeki.config.application["sys.crypt_pass"]
    in_password = Util::String::Crypt.decrypt(in_password, crypt_pass) if encrypted

    user = nil
    login_users(in_account, site: site).each do |u|
      if u.ldap == 1
        ## LDAP Auth
        next unless ou1 = u.groups[0]
        next unless ou2 = ou1.parent
        dn = "uid=#{u.account},ou=#{ou1.ou_name},ou=#{ou2.ou_name},#{Core.ldap.base}"
        next unless Core.ldap.bind(dn, in_password)
        u.password = in_password
      else
        ## DB Auth
        next if in_password != u.password || u.password.to_s == ''
      end
      user = u
      break
    end
    return user
  end

  def encrypt_password
    return if password.blank?
    crypt_pass  = Zomeki.config.application["sys.crypt_pass"]
    Util::String::Crypt.encrypt(password, crypt_pass)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(validate: false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    update_attributes remember_token_expires_at: nil, remember_token: nil
  end

  def root?
    id == ROOT_ID
  end

  def sites
    groups.flat_map(&:sites).uniq
  end

  def site_ids
    sites.map(&:id)
  end

  protected

  def validate_account_uniqueness_in_site
    users = self.class.in_site(sites).where(account: account)
    users = users.where.not(id: id) if persisted?
    root_users = self.class.where(account: account, id: ROOT_ID)

    if [users, root_users].reduce(:union).exists?
      errors.add(:account, :taken_in_site)
    end
  end

  def validate_auth_for_root
    if root? && auth_no != 5
      errors.add(:base, 'システム管理者の権限は変更出来ません。')
      self.auth_no = 5
    end
  end

  def block_root_deletion
    raise "Root user can't be deleted." if root?
  end

  class << self
    def root
      self.where(id: ROOT_ID).first
    end
  end
end
