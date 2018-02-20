class Cms::Importation < ApplicationRecord
  include Sys::Model::Base

  belongs_to :importable, polymorphic: true

  nested_scope :in_site, through: :importable
end
