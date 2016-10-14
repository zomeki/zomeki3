class Sys::Unid < ApplicationRecord
  include Sys::Model::Base
  
  validates :model, :item_id, presence: true
end
