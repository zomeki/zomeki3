class Sys::Task < ActiveRecord::Base
  include Sys::Model::Base

  belongs_to :processable, polymorphic: true
end
