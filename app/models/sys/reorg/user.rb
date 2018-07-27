require 'digest/sha1'
class Sys::Reorg::User < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Auth::Site

  enum_ish :state, [:enabled, :disabled]
  enum_ish :auth_no, [2, 4, 5]
  enum_ish :ldap_state, [1, 0]
  enum_ish :admin_creatable, [true, false]

  has_many :users_groups, foreign_key: :user_id, dependent: :destroy
  has_many :groups, through: :users_groups, source: :group
  has_many :users_roles, foreign_key: :user_id, dependent: :destroy
  has_many :role_names, through: :users_roles, source: :role_name

  accepts_nested_attributes_for :users_groups

  validates :state, :name, :ldap, presence: true
  validates :account, presence: true,
                      format: { with: /\A[\x20-\x7F]*\z/ },
                      uniqueness: { if: :root? }

  validate :validate_auth_for_root
  validate :validate_account_uniqueness_in_site, if: -> { !root? && users_groups.present? }

  nested_scope :in_site, through: :users_groups

  scope :in_group, ->(group) {
    klass = reflect_on_association(:users_groups).klass
    joins(:users_groups).where(klass.table_name.to_sym => { group_id: group })
  }

  def name_with_account
    "#{name}（#{account}）"
  end

  def group
    groups[0]
  end

  def group_id
    group ? group.id : nil
  end

  def root?
    account == Sys::User.root.account
  end

  def sites
    groups.flat_map(&:sites).uniq
  end

  private

  def validate_account_uniqueness_in_site
    users = self.class.in_site(sites).where(account: account)
    users = users.where.not(id: id) if persisted?
    root_users = self.class.where(account: account, id: Sys::User::ROOT_ID)

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

  concerning :Migration do
    included do
      enum_ish :change_state, [:create, :update, :delete]

      belongs_to :sys_user, class_name: 'Sys::User'
      has_many :user_migrations, -> { order(:id) }, dependent: :destroy
      has_many :source_users, through: :user_migrations, source: :source_user
      has_many :invert_user_migrations, -> { order(:id) }, class_name: 'Sys::Reorg::UserMigration', foreign_key: :source_user_id
      has_many :destination_users, through: :invert_user_migrations, source: :user

      accepts_nested_attributes_for :user_migrations, allow_destroy: true

      before_save :mark_destruction_for_blank_migrations
    end

    def detect_change_state
      if sys_user.blank?
        'create'
      else
        new_attrs = attributes.slice(*sys_user.class.column_names)
                              .except('id', 'created_at', 'updated_at')
                              .sort
        old_attrs = sys_user.attributes
                            .except('id', 'created_at', 'updated_at')
                            .sort
        if new_attrs != old_attrs ||
           user_migrations.present? || 
           groups.map(&:sys_group_id).sort != sys_user.groups.map(&:id).sort ||
           role_names.map(&:id).sort != sys_user.role_names.map(&:id).sort
          'update'
        else
          nil
        end
      end
    end

    private

    def mark_destruction_for_blank_migrations
      user_migrations.each do |migration|
        migration.mark_for_destruction if migration.source_user_id.blank?
      end
    end
  end
end
