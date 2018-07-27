class Sys::Reorg::Group < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Tree
  include Cms::Model::Auth::Site

  enum_ish :state, [:enabled, :disabled]
  enum_ish :ldap_state, [1, 0]
  enum_ish :web_state, [:public, :closed]

  belongs_to :parent, class_name: self.name
  has_many :children, -> { order(:sort_no, :code) },
                      foreign_key: :parent_id, class_name: self.name, dependent: :destroy

  has_many :users_groups
  has_many :users, -> { order(:id) }, through: :users_groups

  has_many :site_belongings, class_name: 'Cms::Reorg::SiteBelonging', dependent: :destroy
  has_many :sites, -> { order(:id) }, through: :site_belongings, class_name: 'Cms::Site'

  validates :state, :level_no, :name, :ldap, presence: true
  validates :code, presence: true,
                   format: { with: /\A[\x20-\x7F]*\z/ }
  validates :name_en, presence: true,
                      uniqueness: { scope: :parent_id, unless: :root? },
                      format: { with: /\A[0-9A-Za-z\._-]*\z/i }
  validate :validate_code_uniqueness_in_site

  nested_scope :in_site, through: :site_belongings

  scope :in_group, ->(group) { where(parent_id: group) }

  def ou_name
    "#{code}#{name}"
  end
  
  def full_name
    ancestors.drop(1).map(&:name).join('　')
  end

  def tree_name(prefix: '　　', depth: 0)
    prefix * [level_no - 1 + depth, 0].max + name
  end

  private

  def validate_code_uniqueness_in_site
    groups = self.class.in_site(sites.map(&:id)).where(code: code)
    groups = groups.where.not(id: id) if persisted?
    if groups.exists?
      errors.add(:code, :taken_in_site)
    end
  end

  class << self
    def parent_options(site, origin = nil)
      groups = Sys::Reorg::Group.in_site(site).order(:sort_no, :code, :id)
      groups = groups.where.not(id: origin) if origin
      groups.to_tree.flat_map(&:descendants).map { |g| [g.tree_name, g.id] }
    end
  end

  concerning :Migration do
    included do
      enum_ish :change_state, [:create, :update, :delete]

      belongs_to :sys_group, class_name: 'Sys::Group'
      has_many :group_migrations, -> { order(:id) }, dependent: :destroy
      has_many :source_groups, through: :group_migrations, source: :source_group
      has_many :invert_group_migrations, -> { order(:id) }, class_name: 'Sys::Reorg::GroupMigration', foreign_key: :source_group_id
      has_many :destination_groups, through: :invert_group_migrations, source: :group

      accepts_nested_attributes_for :group_migrations, allow_destroy: true

      before_save :mark_destruction_for_blank_migrations
    end

    def detect_change_state
      if sys_group.blank?
        'create'
      else
        new_attrs = attributes.slice(*sys_group.class.column_names)
                              .except('id', 'created_at', 'updated_at', 'parent_id')
                              .sort
        old_attrs = sys_group.attributes
                             .except('id', 'created_at', 'updated_at', 'parent_id')
                             .sort
        if new_attrs != old_attrs ||
           group_migrations.present? || 
           (parent && parent.sys_group_id != sys_group.parent_id)
          'update'
        else
          nil
        end
      end
    end

    private

    def mark_destruction_for_blank_migrations
      group_migrations.each do |migration|
        migration.mark_for_destruction if migration.source_group_id.blank?
      end
    end
  end
end
