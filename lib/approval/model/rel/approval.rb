module Approval::Model::Rel::Approval
  extend ActiveSupport::Concern

  attr_accessor :in_approval_flow_ids, :in_approval_assignment_ids

  included do
    has_many :approval_requests, class_name: 'Approval::ApprovalRequest', as: :approvable, dependent: :destroy
    with_options if: -> { !in_approval_flow_ids.nil? && state_approvable? } do
      validate :validate_approval_requests
      validate :validate_approval_assignments
      after_save :save_approval_requests
    end
  end

  def approvers
    approval_requests.map(&:current_approvable_approvers).flatten.compact.uniq
  end

  def approval_requesters
    approval_requests.map(&:requester).flatten.compact.uniq
  end

  def approval_participators
    approval_requests.map(&:participators).flatten.compact.uniq
  end

  def approve(user)
    return unless state_approvable?

    approval_requests.each do |approval_request|
      approval_request.approve(user) do |state|
        case state
        when 'progress'
          send_approval_request_mail
        when 'finish'
          send_approved_notification_mail
        end
      end
    end

    if approval_requests.all?(&:finished?)
      yield if block_given?
    end
  end

  def passback(approver, comment: '')
    return unless state_approvable?
    approval_requests.each do |approval_request|
      send_passbacked_notification_mail(approval_request: approval_request, approver: approver, comment: comment)
      approval_request.passback(approver, comment: comment)
    end
    yield if block_given?
  end

  def pullback(comment: '')
    return unless state_approvable?
    approval_requests.each do |approval_request|
      send_pullbacked_notification_mail(approval_request: approval_request, comment: comment)
      approval_request.pullback(comment: comment)
    end
    yield if block_given?
  end

  def send_approval_request_mail
    approval_requests.each do |approval_request|
      approval_request.current_approvable_approvers.each do |approver|
        next if approval_request.requester.email.blank? || approver.email.blank?
  
        Approval::Admin::Mailer.approval_request(from: approval_request.requester.email, to: approver.email, 
          approval_request: approval_request, approver: approver, item: self).deliver_now
      end
    end
  end

  def send_approved_notification_mail
    approval_requests.each do |approval_request|
      approver = approval_request.current_assignments.reorder(approved_at: :desc).first.user
      next if approver.email.blank? || approval_request.requester.email.blank?
  
      Approval::Admin::Mailer.approved_notification(from: approver.email, to: approval_request.requester.email, 
        approval_request: approval_request, approver: approver, item: self).deliver_now
    end
  end

  def send_passbacked_notification_mail(approval_request: nil, approver: nil, comment: '')
    return if approver.email.blank? || approval_request.requester.email.blank?

    Approval::Admin::Mailer.passbacked_notification(from: approver.email, to: approval_request.requester.email,
      approval_request: approval_request, approver: approver, comment: comment, item: self).deliver_now
  end

  def send_pullbacked_notification_mail(approval_request: nil, comment: '')
    approval_request.current_approvers.each do |approver|
      next if approver.email.blank? || approval_request.requester.email.blank?
      Approval::Admin::Mailer.pullbacked_notification(from: approval_request.requester.email, to: approver.email,
        approval_request: approval_request, comment: comment, item: self).deliver_now
    end
  end

  private

  def validate_approval_requests
    in_approval_flow_ids.reject!(&:blank?)
    if in_approval_flow_ids.blank?
      errors.add(:base, '承認フローを選択してください。')
    end
  end

  def validate_approval_assignments
    return unless in_approval_assignment_ids

    in_approval_flow_ids.each do |approval_flow_id|
      if in_approval_assignment_ids[approval_flow_id]
        in_approval_assignment_ids[approval_flow_id].each do |approval_id, user_ids|
          errors.add("承認者", "を選択してください。") if user_ids.blank?
        end
      end
    end
  end

  def save_approval_requests
    in_approval_flow_ids.reject!(&:blank?)
    in_approval_flow_ids.each do |approval_flow_id|
      request = approval_requests.find_by(approval_flow_id: approval_flow_id) ||
        approval_requests.create(user_id: Core.user.id, approval_flow_id: approval_flow_id)

      if in_approval_assignment_ids && (assignments = in_approval_assignment_ids[approval_flow_id])
        request.selected_assignments.destroy_all
        assignments.each do |approval_id, uid_str|
          approval = Approval::Approval.find_by(id: approval_id)
          next unless approval
          uid_str.split(' ').each_with_index do |uids, i|
            uids.split(',').each do |uid|
              request.selected_assignments.create(user_id: uid, selected_index: approval.index, or_group_id: i)
            end
          end
        end
      end

      request.user_id = Core.user.id
      request.save! if request.changed?
      request.reset
    end

    approval_requests.where.not(approval_flow_id: in_approval_flow_ids).destroy_all
  end
end
