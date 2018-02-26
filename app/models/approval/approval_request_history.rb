class Approval::ApprovalRequestHistory < ApplicationRecord
  include Sys::Model::Base

  enum_ish :reason, [:approve, :passback, :pullback]

  belongs_to :request, class_name: 'Approval::ApprovalRequest', required: true
  belongs_to :operator, foreign_key: :user_id, class_name: 'Sys::User', required: true

  nested_scope :in_site, through: :request
end
