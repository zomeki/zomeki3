class Cms::Bracket < ActiveRecord::Base
  include Sys::Model::Base
  belongs_to :owner, polymorphic: true
end
