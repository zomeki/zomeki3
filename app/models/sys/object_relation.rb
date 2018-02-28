class Sys::ObjectRelation < ApplicationRecord
  include Sys::Model::Base

  belongs_to :source, polymorphic: true, required: true
  belongs_to :related, polymorphic: true, required: true

  nested_scope :in_site, through: :source
end
