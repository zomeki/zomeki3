class Sys::UnidRelation < ApplicationRecord
  include Sys::Model::Base
  
  validates :unid, :rel_unid, :rel_type, presence: true
end
