class Cms::Concept < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Tree
  include Cms::Model::Rel::Site
  include Cms::Model::Auth::Site

  enum_ish :state, [:public, :closed], default: :public

  belongs_to :parent, foreign_key: :parent_id, class_name: self.name
  has_many :children, -> { order(:sort_no) },
                      foreign_key: :parent_id, class_name: self.name, dependent: :destroy

  has_many :layouts, -> { order(:name) }, dependent: :destroy
  has_many :pieces, -> { order(:name) }, dependent: :destroy
  has_many :contents, -> { order(:name) }, dependent: :destroy
  has_many :data_files, dependent: :destroy
  has_many :data_file_nodes, dependent: :destroy

  validates :site_id, :state, :level_no, :name, presence: true

  validate {
    errors.add :parent_id, :invalid if id != nil && id == parent_id
  }

  scope :readable_for, ->(user) {
    rel = where(state: 'public')
    if user.has_auth?(:manager)
      rel
    else
      role_ids = Sys::UsersRole.select(:role_id).where(user_id: user.id)
      rel.where(id: Sys::ObjectPrivilege.select(:concept_id).where(action: 'read', role_id: role_ids))
    end
  }

  def tree_name(prefix: '　　', depth: 0)
    prefix * [level_no - 1 + depth, 0].max + name
  end

  class << self
    def parent_options(site, origin = nil)
      concepts = site.concepts
      concepts = concepts.where.not(id: origin) if origin
      concepts.to_tree.flat_map(&:descendants).map { |c| [c.tree_name, c.id] }
    end
  end
end
