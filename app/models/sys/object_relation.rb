class Sys::ObjectRelation < ActiveRecord::Base
  include Sys::Model::Base
  belongs_to :source, polymorphic: true, required: true
  belongs_to :related, polymorphic: true, required: true
end
