class Approval::ApprovalRequest < ApplicationRecord
  include Sys::Model::Base

  belongs_to :requester, foreign_key: :user_id, class_name: 'Sys::User'
  validates :user_id, presence: true
  belongs_to :approvable, polymorphic: true
  validates :approvable_type, :approvable_id, presence: true
  belongs_to :approval_flow
  validates :approval_flow_id, presence: true

  has_many :current_assignments, -> { where(selected_index: nil).order(:or_group_id, :id) },
    class_name: 'Approval::Assignment', as: :assignable, dependent: :destroy
  has_many :selected_assignments, -> { where.not(selected_index: nil).order(:or_group_id, :id) },
    class_name: 'Approval::Assignment', as: :assignable, dependent: :destroy
  has_many :current_approvers, through: :current_assignments, source: :user
  has_many :histories, -> { order(updated_at: :desc, created_at: :desc) },
           foreign_key: :request_id, class_name: 'Approval::ApprovalRequestHistory', dependent: :destroy

  after_initialize :set_defaults

  def current_approval
    approval_flow.approvals.find_by(index: current_index)
  end

  def min_index
    0
  end

  def max_index
    approval_flow.approvals.map(&:index).max
  end

  def approve(user)
    return false unless current_approvers.include?(user)

    transaction do
      histories.create(operator: user, reason: 'approve', comment: '')
      if assignment = current_assignments.find_by(user_id: user.id)
        current_assignments.where(or_group_id: assignment.or_group_id).update_all(approved_at: Time.now)
      end
      current_assignments.reload # flush cache
    end

    if current_assignments.all?(&:approved_at)
      if current_index == max_index
        yield('finish') if block_given?
      else
        transaction do
          increment!(:current_index)
          create_current_assignments
        end
        yield('progress') if block_given?
      end
    end

    return true
  end

  def passback(approver, comment: '')
    return false unless current_approvers.include?(approver)

    transaction do
      histories.create(operator: approver, reason: 'passback', comment: comment || '')
      reset
    end

    return true
  end

  def pullback(comment: '')
    transaction do
      histories.create(operator: self.requester, reason: 'pullback', comment: comment || '')
      reset
    end

    return true
  end

  def finished?
    current_index == max_index && current_assignments.all?(&:approved_at)
  end

  def reset
    transaction do
      update_column(:current_index, min_index)
      create_current_assignments
    end
  end

  def current_selected_assignments
    selected_assignments.where(selected_index: current_index)
  end

  def selected_approvers_label(approval)
    approvers = selected_assignments.where(selected_index: approval.index).group_by(&:or_group_id).map do |_, asns|
      asns.map(&:assigner_label).join(' or ')
    end
    approvers.join(' and ')
  end

  def current_approvable_approvers
    current_assignments.reject(&:approved_at).map(&:user).compact
  end

  def participators
    users = [requester]
    approval_flow.approvals.each do |approval|
      users +=
        if approval.approval_type_select?
          assignments = selected_assignments.where(selected_index: approval.index).all
          assignments.present? ? assignments.map(&:user) : approval.assignments.map(&:user)
        else
          approval.assignments.map(&:user)
        end
    end
    users.compact.uniq
  end

  private

  def set_defaults
    self.current_index = min_index if has_attribute?(:current_index) && current_index.nil?
  end

  def create_current_assignments
    current_assignments.destroy_all

    if current_approval.approval_type_select?
      current_selected_assignments.each do |asn|
        current_assignments.create(user_id: asn.user_id, or_group_id: asn.or_group_id)
      end
    else
      current_approval.assignments.each do |asn|
        asn.assigners.each do |assigner|
          current_assignments.create(user_id: assigner.id, or_group_id: asn.or_group_id)
        end
      end
    end

    reload # flush cache
  end
end
