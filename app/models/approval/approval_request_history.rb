class Approval::ApprovalRequestHistory < ApplicationRecord
  include Sys::Model::Base

  REASON_OPTIONS = [['承認', 'approve'], ['差し戻し', 'passback'], ['引き戻し', 'pullback']]

  belongs_to :request, :class_name => 'Approval::ApprovalRequest'
  validates :request_id, presence: true
  belongs_to :operator, :foreign_key => :user_id, :class_name => 'Sys::User'
  validates :user_id, presence: true

  def reason_title
    REASON_OPTIONS.detect{|o| o.last == reason }.try(:first)
  end
end
