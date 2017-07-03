class Cms::Bracket < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Rel::Site

  belongs_to :owner, polymorphic: true
  belongs_to :concept, class_name: 'Cms::Concept'

  scope :with_prefix, ->(names) {
    conds = names.map { |name| arel_table[:name].matches("#{name}%") }
    where(conds.reduce(:or))
  }
end
