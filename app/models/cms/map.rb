class Cms::Map < ApplicationRecord
  include Sys::Model::Base

  belongs_to :map_attachable, polymorphic: true
  has_many :markers, class_name: 'Cms::MapMarker', dependent: :destroy
  accepts_nested_attributes_for :markers

  nested_scope :in_site, through: :map_attachable
end
