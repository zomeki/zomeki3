class Sys::Reorg::UsersGroup < ApplicationRecord
  include Sys::Model::Base

  belongs_to :user
  belongs_to :group

  validates :group_id, presence: true

  nested_scope :in_site, through: :group

  class << self
    def group_options(site)
      Sys::Reorg::Group.in_site(site).order(:sort_no, :code, :id).to_tree
                       .flat_map(&:descendants)
                       .reject(&:root?)
                       .map { |g| [g.tree_name(depth: -1), g.id]}
    end
  end
end
