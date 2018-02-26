class Map::MarkerIcon < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  belongs_to :content, class_name: 'Map::Content::Marker'
  belongs_to :relatable, polymorphic: true
end
