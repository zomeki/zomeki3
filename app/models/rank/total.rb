class Rank::Total < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Rel::Content

  # Content
  belongs_to :content, class_name: 'Rank::Content::Rank', required: true

  def page_title
    self[:page_title].gsub(' | ' + content.site.name, '')
  end
end
