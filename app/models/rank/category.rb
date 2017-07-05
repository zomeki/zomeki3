class Rank::Category < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Rel::Content

  belongs_to :content, foreign_key: :content_id, class_name: 'Rank::Content::Rank'
end
