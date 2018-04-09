class Approval::ApprovalFlow < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  column_attribute :sort_no, default: 10

  # Content
  belongs_to :content, class_name: 'Approval::Content::ApprovalFlow', required: true

  belongs_to :group, class_name: 'Sys::Group'

  has_many :approvals, dependent: :destroy
  has_many :approval_requests, dependent: :destroy

  validates :title, presence: true

  scope :for_user, ->(user) {
    where(group_id: [nil] + user.groups.map(&:id))
  }
end
