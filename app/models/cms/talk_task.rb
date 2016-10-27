class Cms::TalkTask < ApplicationRecord
  include Sys::Model::Base
  
  validates :path, presence: true
end
