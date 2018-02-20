class Cms::SearchText < ApplicationRecord
  include Sys::Model::Base

  belongs_to :searchable, polymorphic: true

  nested_scope :in_site, through: :searchable
end
