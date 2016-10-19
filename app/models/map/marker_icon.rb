class Map::MarkerIcon < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Auth::Content

  belongs_to :content, foreign_key: :content_id, class_name: 'Map::Content::Marker'
  belongs_to :relatable, polymorphic: true
end
