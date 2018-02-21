class Sys::Group < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Tree
  include Cms::Model::Site
  include Cms::Model::Auth::Site

  enum_ish :state, [:enabled, :disabled]
  enum_ish :ldap_state, [1, 0]
  enum_ish :web_state, [:public, :closed]

  belongs_to :parent, class_name: self.name
  has_many :children, -> { order(:sort_no, :code) },
                      foreign_key: :parent_id, class_name: self.name, dependent: :destroy

  has_many :users_groups, class_name: 'Sys::UsersGroup'
  has_many :users, -> { order(:id) }, through: :users_groups

  has_many :site_belongings, class_name: 'Cms::SiteBelonging', dependent: :destroy
  has_many :sites, -> { order(:id) }, through: :site_belongings, class_name: 'Cms::Site'

  before_save :disable_users, if: -> { state_changed? && state == 'disabled' }
  before_destroy :disable_users

  validates :state, :level_no, :name, :ldap, presence: true
  validates :code, presence: true,
                   format: { with: /\A[\x20-\x7F]*\z/ }
  validates :name_en, presence: true,
                      uniqueness: { scope: :parent_id, unless: :root? },
                      format: { with: /\A[0-9A-Za-z\._-]*\z/i }
  validate :validate_disable_state
  validate :validate_code_uniqueness_in_site

  define_site_scope :site_belongings

  scope :in_group, ->(group) { where(parent_id: group.id) }

  def deletable_group?
    group_ids = descendants.map(&:id)
    !self.class.where(id: group_ids - [id], state: 'enabled').exists? &&
      !Sys::User.joins(:groups).where(sys_groups: { id: group_ids }).exists? &&
      !Sys::Creator.where(group_id: group_ids, creatable_type: 'GpArticle::Doc').exists?
  end

  def ou_name
    "#{code}#{name}"
  end
  
  def full_name
    n = name
    n = "#{parent.name}　#{n}" if parent && parent.level_no > 1
    n
  end

  def tree_name(opts = {})
    opts.reverse_merge!(prefix: '　　', depth: 0)
    opts[:prefix] * [level_no - 1 + opts[:depth], 0].max + name
  end

  def descendants_in_site(site)
    descendants do |child|
      rel = child.in_site(site)
      rel = yield(rel) || rel if block_given?
      rel
    end
  end

  def descendants_for_option(groups=[])
    descendants.map {|g| [g.tree_name(depth: -1), g.id] }
  end

  private

  def validate_code_uniqueness_in_site
    groups = self.class.in_site(sites.map(&:id)).where(code: code)
    groups = groups.where.not(id: id) if persisted?
    if groups.exists?
      errors.add(:code, :taken_in_site)
    end
  end

  def disableable?
    children.size == 0 &&
      !users.where(state: 'enabled', auth_no: 5).exists?
  end

  def validate_disable_state
    if state_changed? && state == 'disabled' && !disableable?
      errors.add(:base, 'このグループは無効にできません。')
    end
  end

  def disable_users
    users.each do |user|
      if user.groups.size == 1
        u = Sys::User.find_by(id: user.id)
        u.state = 'disabled'
        u.save
      end
    end
    return true
  end

  def delete_users
    users.each do |user|
      if user.groups.size == 1
        user.destroy
      end
    end
    return true
  end

  class << self
    def readable
      all
    end
  end
end
