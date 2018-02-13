class Rank::Category < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Rel::Content

  belongs_to :content, class_name: 'Rank::Content::Rank'
end
