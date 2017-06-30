class Cms::Importation < ApplicationRecord
  include Sys::Model::Base

  belongs_to :importable, polymorphic: true
end
