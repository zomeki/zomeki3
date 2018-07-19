class Sys::Bookmark < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Tree
  include Sys::Model::Auth::Free

  belongs_to :parent, class_name: self.name
  has_many :children, -> { order(:sort_no, :id) },
                      foreign_key: :parent_id, class_name: self.name, dependent: :destroy

  belongs_to :user

  validates :title, :url, presence: true
  validate :validate_level_no

  nested_scope :in_site, through: :user

  def tree_name(prefix: '　　', depth: 0)
    prefix * [level_no - 1 + depth, 0].max + title
  end

  private

  def validate_level_no
    if children.present? && level_no >= 2
      errors.add(:parent_id, 'は空にしてください。下位の階層を持つブックマークは移動できません。')
    end
  end

  class << self
    def parent_options(user, origin = nil)
      bookmarks = self.where(user_id: user, level_no: 1).order(:sort_no, :id)
      bookmarks = bookmarks.where.not(id: origin) if origin
      bookmarks.to_tree.flat_map(&:descendants).map { |b| [b.tree_name, b.id] }
    end
  end
end
