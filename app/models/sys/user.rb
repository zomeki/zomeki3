require 'digest/sha1'
class Sys::User < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  include StateText

  ROOT_ID = 1

  has_many :users_groups, foreign_key: :user_id, class_name: 'Sys::UsersGroup', dependent: :destroy
  has_many :groups, through: :users_groups, source: :group
  has_many :users_roles, foreign_key: :user_id, class_name: 'Sys::UsersRole', dependent: :destroy
  has_many :role_names, through: :users_roles, source: :role_name
  has_many :operation_logs, class_name: 'Sys::OperationLog'
  has_many :gp_article_holds, class_name: 'GpArticle::Hold', dependent: :destroy

  attr_accessor :in_group_id

  validates :state, :name, :ldap, presence: true
  validates :in_group_id, presence: true, if: -> { in_group_id == '' }
  validate :admin_auth_no_fixation

  validates :account, presence: true,
                      format: { with: /\A[\x20-\x7F]*\z/ },
                      uniqueness: { if: :root? }
  validate :validate_account_uniqueness_in_site, if: -> { !root? && @in_group_id }

  after_save :save_group, if: -> { @_in_group_id_changed }

  before_destroy :block_root_deletion

  scope :in_site, ->(site) { joins(users_groups: :site_belongings).where(cms_site_belongings: { site_id: Array(site).map(&:id) }) }
  scope :in_group, ->(group) { joins(:users_groups).where(sys_users_groups: { group_id: group.id }) }

  scope :search_with_params, ->(params = {}) {
    rel = all
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_id'
        rel.where!(id: v)
      when 's_state'
        rel.where!(state: v)
      when 's_account'
        rel.where!(arel_table[:account].matches("%#{escape_like(v)}%"))
      when 's_name'
        rel.where!(arel_table[:name].matches("%#{escape_like(v)}%"))
      when 's_email'
        rel.where!(arel_table[:email].matches("%#{escape_like(v)}%"))
      when 's_group_id'
        rel.joins!(:groups).where!(sys_groups: {id: v == 'no_group' ? nil : v})
      end
    end
    rel
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

  def authes
    #[['なし',0], ['投稿者',1], ['作成者',2], ['編集者',3], ['設計者',4], ['管理者',5]]
    [['作成者',2], ['設計者',4], ['管理者',5]]
  end

  def authes_exclude_admin
    [['作成者',2], ['設計者',4]]
  end

  def auth_name
    authes.each {|a| return a[0] if a[1] == auth_no }
    return nil
  end

  def ldap_states
    [['同期',1],['非同期',0]]
  end

  def ldap_label
    ldap_states.each {|a| return a[0] if a[1] == ldap }
    return nil
  end

  def name_with_id
    "#{name}（#{id}）"
  end

  def name_with_account
    "#{name}（#{account}）"
  end

  def label(name)
    case name; when nil; end
  end

  def group(load = nil)
    return @group if @group && load
    @group = groups(load).size == 0 ? nil : groups[0]
  end

  def group_id(load = nil)
    (g = group(load)) ? g.id : nil
  end

  def in_group_id
    unless @in_group_id
      @in_group_id = group.try(:id)
    end
    @in_group_id
  end

  def in_group_id=(value)
    @_in_group_id_changed = true
    @in_group_id = value
  end

  def has_auth?(name)
    auth = {
      :none     => 0, # なし  操作不可
      :reader   => 1, # 読者  閲覧のみ
      :creator  => 2, #作成者 記事作成者
      :editor   => 3, #編集者 データ作成者
      :designer => 4, #設計者 デザイン作成者
      :manager  => 5, #管理者 設定作成者
    }
    raise "Unknown authority name: #{name}" unless auth.has_key?(name)
    return auth[name] <= auth_no
  end

  def has_priv?(action, options = {})
    unless options[:auth_off]
      return true if has_auth?(:manager)
    end
    return nil unless options[:item]

    role_ids = Sys::ObjectPrivilege.where(action: action.to_s, privilegable: options[:item]).pluck(:role_id)
    return false if role_ids.size == 0

    users_roles.where(role_id: role_ids).exists?
  end

  def delete_group_relations
    Sys::UsersGroup.where(user_id: id).delete_all
    return true
  end

  ## -----------------------------------
  ## Authenticates

  def self.login_users(account, site: nil)
    root_users = self.where(state: 'enabled', account: account, id: ROOT_ID)
    users = self.where(state: 'enabled', account: account)
    users = users.in_site(site) if site
    self.union([root_users, users])
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
    save(:validate => false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    #save(:validate => false)
    update_attributes :remember_token_expires_at => nil, :remember_token => nil
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
    group = Sys::Group.find_by(id: in_group_id)

    users = self.class.where(account: account)
    users = users.in_site(group.sites) if group && group.sites
    users = users.where.not(id: id) if persisted?
    root_users = self.class.where(account: account, id: ROOT_ID)

    if self.class.union([users, root_users]).exists?
      errors.add(:account, :taken_in_site)
    end
  end

  def password_required?
    password.blank?
  end

  def save_group
    exists = (users_groups.size > 0)

    users_groups.each_with_index do |rel, idx|
      if idx == 0 && !in_group_id.blank?
        if rel.group_id != in_group_id
          rel.class.where(user_id: rel.user_id, group_id: rel.group_id).update_all(group_id: in_group_id)
          rel.group_id = in_group_id
        end
      else
        rel.class.where(user_id: rel.user_id, group_id: rel.group_id).delete_all
      end
    end

    if !exists && !in_group_id.blank?
      rel = Sys::UsersGroup.create(
        :user_id  => id,
        :group_id => in_group_id
      )
    end

    return true
  end

  def block_root_deletion
    raise "Root user can't be deleted." if self.root?
  end

  def admin_auth_no_fixation
    return unless self.root?

    unless self.auth_no == 5
      errors.add(:base, 'システム管理者の権限は変更出来ません。')
      self.auth_no = 5
    end
  end

  class << self
    def readable
      all
    end

    def root
      self.where(id: ROOT_ID).first
    end
  end
end
