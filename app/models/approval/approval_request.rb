class Approval::ApprovalRequest < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  attribute :current_index, :integer, default: 0

  belongs_to :requester, foreign_key: :user_id, class_name: 'Sys::User'
  belongs_to :approvable, polymorphic: true
  belongs_to :approval_flow

  has_many :assignments, -> { where(selected_index: nil).order(:or_group_id, :id) },
    class_name: 'Approval::Assignment', as: :assignable, dependent: :destroy
  has_many :selected_assignments, -> { where.not(selected_index: nil).order(:or_group_id, :id) },
    class_name: 'Approval::Assignment', as: :assignable, dependent: :destroy
  has_many :histories, -> { order(updated_at: :desc, created_at: :desc) },
           foreign_key: :request_id, class_name: 'Approval::ApprovalRequestHistory', dependent: :destroy

  validates :user_id, presence: true
  validates :approval_flow_id, presence: true

  define_site_scope :approval_flow

  def current_approval
    approval_flow.approvals.find_by(index: current_index)
  end

  def current_assignments
    assignments
  end

  def current_selected_assignments
    selected_assignments.where(selected_index: current_index)
  end

  def current_approvers
    current_assignments.map(&:user)
  end

  def current_approvable_approvers
    current_assignments.reject(&:approved_at).map(&:user).compact
  end

  def participators
    users = [requester]
    approval_flow.approvals.each do |approval|
      users += if approval.approval_type_select?
                 selected_assignments.where(selected_index: approval.index).map(&:user)
               else
                 approval.assignments.map(&:user)
               end
    end
    users.compact.uniq
  end

  def min_index
    0
  end

  def max_index
    approval_flow.approvals.map(&:index).max
  end

  def assignments_at(index)
    if index == current_index
      current_assignments
    else
      approval = approval_flow.approvals.detect { |a| a.index == index }
      return [] unless approval
      if approval.approval_type_select?
        selected_assignments.select { |sa| sa.selected_index == index }
      else
        approval.assignments
      end
    end
  end

  def or_group_assignments_at(index)
    assignments_at(index).group_by(&:or_group_id)
  end

  def approvers_label_at(index)
    approvers = []
    or_group_assignments_at(index).each do |ogid, asns|
      approvers << '(' + asns.flat_map { |asn| asn.assigners(requester) }.uniq.map(&:name).join(' or ') + ')'
    end
    approvers.join(' and ')
  end

  def approve(user)
    return false unless current_approvers.include?(user)

    transaction do
      histories.create(operator: user, reason: 'approve', comment: '')
      or_group_ids = current_assignments.where(user_id: user.id).pluck(:or_group_id)
      current_assignments.where(or_group_id: or_group_ids).update_all(approved_at: Time.now)
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

  private

  def create_current_assignments
    current_assignments.destroy_all

    if current_approval.approval_type_select?
      current_selected_assignments.each do |asn|
        current_assignments.create(user_id: asn.user_id, or_group_id: asn.or_group_id)
      end
    else
      current_approval.assignments.each do |asn|
        asn.assigners(requester).each do |assigner|
          current_assignments.create(user_id: assigner.id, or_group_id: asn.or_group_id)
        end
      end
    end

    reload # flush cache
  end
end
