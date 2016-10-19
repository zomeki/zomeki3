class Sys::ObjectRelation < ApplicationRecord
  include Sys::Model::Base
  belongs_to :source, polymorphic: true, required: true
  belongs_to :related, polymorphic: true, required: true
end
