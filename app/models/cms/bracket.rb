class Cms::Bracket < ApplicationRecord
  include Sys::Model::Base
  belongs_to :owner, polymorphic: true

  scope :with_prefix, ->(names) {
    conds = names.map { |name| arel_table[:name].matches("#{name}%") }
    where(conds.reduce(:or))
  }
end
