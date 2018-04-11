class Cms::Bracket < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Site

  belongs_to :owner, polymorphic: true
  belongs_to :concept, class_name: 'Cms::Concept'

  scope :with_prefix, ->(names) {
    conds = names.map { |name| arel_table[:name].matches("#{name}%") }
    where(conds.reduce(:or))
  }

  class << self
    def bracket_type(item)
      case
      when item.is_a?(Cms::Piece)
        'piece'
      when item.is_a?(Cms::DataText)
        'text'
      when item.is_a?(Cms::DataFile)
        item.node ? "file/#{item.node.name}" : 'file'
      else
        raise "unexpected item: #{item}"
      end
    end
  end
end
