class Cms::Importation < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  belongs_to :importable, polymorphic: true

  define_site_scope :importable
end
