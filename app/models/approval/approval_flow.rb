class Approval::ApprovalFlow < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  attribute :sort_no, :integer, default: 10

  # Content
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Approval::Content::ApprovalFlow'
  validates :content_id, presence: true

  belongs_to :group, :class_name => 'Sys::Group'

  has_many :approvals, :dependent => :destroy
  has_many :approval_requests, :dependent => :destroy

  validates :title, :presence => true

  scope :for_user, ->(user) {
    where(group_id: [nil] + user.groups.map(&:id))
  }
end
