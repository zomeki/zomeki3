class Approval::ApprovalRequestHistory < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  REASON_OPTIONS = [['承認', 'approve'], ['差し戻し', 'passback'], ['引き戻し', 'pullback']]

  belongs_to :request, class_name: 'Approval::ApprovalRequest', required: true
  belongs_to :operator, foreign_key: :user_id, class_name: 'Sys::User', required: true

  define_site_scope :request

  def reason_title
    REASON_OPTIONS.detect{|o| o.last == reason }.try(:first)
  end
end
