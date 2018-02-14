class Approval::ApprovalRequestHistory < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  enum_ish :reason, [:approve, :passback, :pullback]

  belongs_to :request, :class_name => 'Approval::ApprovalRequest'
  validates :request_id, presence: true
  belongs_to :operator, :foreign_key => :user_id, :class_name => 'Sys::User'
  validates :user_id, presence: true

  define_site_scope :request
end
