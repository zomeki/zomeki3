class Sys::Reorg::GroupMigration < ApplicationRecord
  include Sys::Model::Base

  belongs_to :group
  belongs_to :source_group, class_name: 'Sys::Reorg::Group'

  nested_scope :in_site, through: :group

  class << self
    def source_group_options(site)
      Sys::Reorg::Group.in_site(site).order(:sort_no, :code, :id).to_tree.flat_map(&:descendants)
                       .reject(&:root?).map { |g| [g.tree_name(depth: -1), g.id] }
    end
  end
end
