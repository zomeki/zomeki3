module Approval::Model::Rel::Approval
  extend ActiveSupport::Concern

  attr_accessor :in_approval_flow_ids, :in_approval_assignment_ids

  included do
    has_many :approval_requests, class_name: 'Approval::ApprovalRequest', as: :approvable, dependent: :destroy

    after_save :save_approval_requests

    with_options if: -> { state_approvable? } do
      validate :validate_approval_requests
      validate :validate_approval_assignments
    end

    scope :approval_requested_by, ->(user) {
      all.left_joins(:approval_requests)
         .where(state: 'approvable')
         .where(Approval::ApprovalRequest.table_name => { user_id: user })
    }
    scope :approvables_for, ->(user) {
      assignments = Approval::Assignment.arel_table
      selected_assignments = Approval::Assignment.arel_table.alias('selected_assignments_approval_approval_requests')
      all.left_joins(approval_requests: [approval_flow: [approvals: :assignments],  selected_assignments: []])
         .where(state: 'approvable')
         .where([assignments[:user_id].eq(user.id).and(assignments[:approved_at].eq(nil)),
                 selected_assignments[:user_id].eq(user.id).and(selected_assignments[:approved_at].eq(nil))].reduce(:or))
    }
    scope :creator_or_approvables, ->(user) {
      creators = Sys::Creator.arel_table
      approval_requests = Approval::ApprovalRequest.arel_table
      assignments = Approval::Assignment.arel_table
      selected_assignments = Approval::Assignment.arel_table.alias('selected_assignments_approval_approval_requests')
      all.joins(:creator)
         .left_joins(approval_requests: [approval_flow: [approvals: :assignments],  selected_assignments: []])
         .where([creators[:user_id].eq(user.id),
                 approval_requests[:user_id].eq(user.id),
                 assignments[:user_id].eq(user.id),
                 selected_assignments[:user_id].eq(user.id)].reduce(:or))
    }
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

  def approvable?(user)
    state_approvable? && approvers.include?(user)
  end

  def passbackable?(user)
    state_approvable? && approvers.include?(user)
  end

  def pullbackable?(user)
    state_approvable? && approval_requesters.include?(user)
  end

  def approve(user)
    approval_requests.each do |approval_request|
      approval_request.approve(user) do |state|
        yield(approval_request) if block_given?
      end
    end
  end

  def passback(approver, comment: '')
    approval_requests.each do |approval_request|
      approval_request.passback(approver, comment: comment)
    end
  end

  def pullback(comment: '')
    approval_requests.each do |approval_request|
      approval_request.pullback(comment: comment)
    end
  end

  private

  def validate_approval_requests
    if in_approval_flow_ids.blank? || in_approval_flow_ids.reject!(&:blank?)
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
    return if in_approval_flow_ids.blank?

    in_approval_flow_ids.reject!(&:blank?)
    in_approval_flow_ids.each do |approval_flow_id|
      request = approval_requests.where(approval_flow_id: approval_flow_id).first_or_create(user_id: Core.user.id)

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
