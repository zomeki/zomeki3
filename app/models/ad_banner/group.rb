class AdBanner::Group < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  default_scope { order(:sort_no) }

  attribute :sort_no, :integer, default: 10

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'AdBanner::Content::Banner'
  validates :content_id, presence: true

  # Proper
  has_many :banners, :foreign_key => :group_id, :class_name => 'AdBanner::Banner'

  validates :name, :presence => true
  validates :title, :presence => true

  before_destroy :uncategorize

  private

  def uncategorize
    banners.clear
  end
end
