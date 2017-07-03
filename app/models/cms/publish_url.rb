class Cms::PublishUrl < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Rel::Node

  belongs_to :publishable, polymorphic: true
  belongs_to :content, class_name: 'Cms::Content'
end
