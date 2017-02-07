class Approval::Approval < ApplicationRecord
  include Sys::Model::Base

  TYPE_OPTIONS = [['固定', 'fix'], ['選択', 'select']]

  default_scope { order(:approval_flow_id, :index) }

  belongs_to :approval_flow
  validates :approval_flow_id, presence: true

  has_many :assignments, :as => :assignable, :dependent => :destroy
  has_many :approvers, :through => :assignments, :source => :user

  validates :index, presence: true, uniqueness: { scope: [:approval_flow_id] }

  after_initialize :set_defaults

  def approval_type_select?
    approval_type == 'select'
  end

  def approval_type_title
    TYPE_OPTIONS.detect { |o| o.last == approval_type }.try(:first)
  end

  def approvers_label
    approvers = assignments.group_by(&:or_group_id).map do |_, asns|
      asns.map(&:assigner_label).join(' or ')
    end
    if approval_type_select?
      "[#{approvers.join(', ')}]"
    else
      approvers = approvers.map { |a| "(#{a})" } if approvers.size > 1
      approvers.join(' and ')
    end
  end

  def approvers_label_for_fix
    approvers = []
    assignments.group_by(&:or_group_id).each do |_, asns|
      approvers << asns.flat_map(&:assigners).map(&:name).join(' or ')
    end
    approvers.join(' and ')
  end

  def approvers_options_for_select
    opts = []
    assignments.group_by(&:or_group_id).map do |_, asns|
      if asns.size == 1 && asns.first.assign_type_group_users?
        asns.flat_map(&:assigners).each do |user|
          opts << [user.name, user.id.to_s] if user != Core.user
        end
      else
        assigners = asns.flat_map(&:assigners) - [Core.user]
        label = assigners.map(&:name).join(' or ')
        value = assigners.map(&:id).join(',')
        opts << [label, value]
      end
    end
    opts.uniq
  end

  private

  def set_defaults
    self.approval_type ||= TYPE_OPTIONS.first.last if self.has_attribute?(:approval_type)
    self.index ||= approval_flow.approvals.count if self.has_attribute?(:index)
  end
end
