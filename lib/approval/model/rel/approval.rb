module Approval::Model::Rel::Approval
  extend ActiveSupport::Concern

  attr_accessor :in_approval_flow_ids, :in_approval_assignment_ids

  included do
    has_many :approval_requests, class_name: 'Approval::ApprovalRequest', as: :approvable, dependent: :destroy
    with_options if: -> { !in_approval_flow_ids.nil? && state_approvable? } do
      validate :validate_approval_requests
      after_save :save_approval_requests
    end
  end

  def approvers
    approval_requests.inject([]){|u, r| u | r.current_assignments.map{|a| a.user unless a.approved_at }.compact }
  end

  def approval_requesters
    approval_requests.inject([]){|u, r| u.include?(r.requester) ? u : u.push(r.requester) }
  end

  def approval_participators
    users = []
    approval_requests.each do |approval_request|
      users << approval_request.requester
      approval_request.approval_flow.approvals.each do |approval|
        _approvers = approval.approvers
        ids = approval_request.select_assignments_ids(approval)
        _approvers = _approvers.select{|a| ids.index(a.id.to_s)} if approval.select_approve?
        users.concat(_approvers)
      end
    end
    return users.uniq
  end

  def approve(user, request = nil)
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
      assginments = approval_request.current_select_assignments
      approval_request.current_assignments.map{|a| a.user unless a.approved_at }.compact.each do |approver|
        next if !assginments.blank? && !assginments.include?(approver.id.to_s)
        next if approval_request.requester.email.blank? || approver.email.blank?
  
        Approval::Admin::Mailer.approval_request(from: approval_request.requester.email, to: approver.email, 
          approval_request: approval_request, approver: approver, item: self).deliver
      end
    end
  end

  def send_approved_notification_mail
    approval_requests.each do |approval_request|
      approver = approval_request.current_assignments.reorder(approved_at: :desc).first.user
      next if approver.email.blank? || approval_request.requester.email.blank?
  
      Approval::Admin::Mailer.approved_notification(from: approver.email, to: approval_request.requester.email, 
        approval_request: approval_request, approver: approver, item: self).deliver
    end
  end

  def send_passbacked_notification_mail(approval_request: nil, approver: nil, comment: '')
    return if approver.email.blank? || approval_request.requester.email.blank?

    Approval::Admin::Mailer.passbacked_notification(from: approver.email, to: approval_request.requester.email,
      approval_request: approval_request, approver: approver, comment: comment, item: self).deliver
  end

  def send_pullbacked_notification_mail(approval_request: nil, comment: '')
    approval_request.current_approvers.each do |approver|
      next if approver.email.blank? || approval_request.requester.email.blank?
      Approval::Admin::Mailer.pullbacked_notification(from: approval_request.requester.email, to: approver.email,
        approval_request: approval_request, comment: comment, item: self).deliver
    end
  end

  private

  def validate_approval_requests
    in_approval_flow_ids.reject!(&:blank?)
    if in_approval_flow_ids.blank?
      errors.add(:base, '承認フローを選択してください。')
    else
      if in_approval_assignment_ids
        in_approval_flow_ids.each do |approval_flow_id|
          if in_approval_assignment_ids[approval_flow_id]
            in_approval_assignment_ids[approval_flow_id].each do |approval_id, value|
              errors.add("承認者", "を選択してください。") if value.blank?
            end
          end
        end
      end
    end
  end

  def save_approval_requests
    in_approval_flow_ids.reject!(&:blank?)
    in_approval_flow_ids.each do |approval_flow_id|
      request = approval_requests.find_by(approval_flow_id: approval_flow_id) ||
        approval_requests.create(user_id: Core.user.id, approval_flow_id: approval_flow_id)

      assignments = {}.with_indifferent_access
      if in_approval_assignment_ids && in_approval_assignment_ids[approval_flow_id]
        in_approval_assignment_ids[approval_flow_id].each do |approval_id, value|
          assignments["approval_#{approval_id}"] = "#{value}"
        end
      end

      request.select_assignment = assignments
      request.user_id = Core.user.id
      request.save! if request.changed?
      request.reset
    end

    approval_requests.where.not(approval_flow_id: in_approval_flow_ids).destroy_all
  end
end
