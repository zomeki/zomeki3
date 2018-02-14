class Approval::Approval < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Site

  default_scope { order(:approval_flow_id, :index) }

  enum_ish :approval_type, [:fix, :select], default: :fix

  belongs_to :approval_flow
  validates :approval_flow_id, presence: true

  has_many :assignments, :as => :assignable, :dependent => :destroy
  has_many :approvers, :through => :assignments, :source => :user

  validates :index, presence: true, uniqueness: { scope: [:approval_flow_id] }

  after_initialize :set_defaults

  define_site_scope :approval_flow

  def approval_type_select?
    approval_type == 'select'
  end

  def approvers_label
    approver_labels = assignments.group_by(&:or_group_id).map do |_, asns|
      asns.map(&:assigner_label)
    end
    approver_labels = approver_labels.map do |labels|
      label = labels.join(' or ')
      if approver_labels.size > 1 && labels.size > 1
        "(#{label})"
      else
        label
      end
    end

    label = approver_labels.join(' and ')
    if approval_type_select?
      "[#{label}]"
    else
      label
    end
  end

  def or_group_assignments
    assignments.group_by(&:or_group_id)
  end

  def approvers_options(requester)
    opts = []
    or_group_assignments.map do |ogid, asns|
      if asns.size == 1 && asns.first.assign_type_group_users?
        asns.flat_map {|asn| asn.assigners(requester) }.uniq.each do |user|
          opts << [user.name, user.id.to_s]
        end
      else
        assigners = asns.flat_map { |asn| asn.assigners(requester) }.uniq
        label = assigners.map(&:name).join(' or ')
        value = assigners.map(&:id).join(',')
        opts << [label, value]
      end
    end
    opts.uniq
  end

  private

  def set_defaults
    self.index ||= approval_flow.approvals.count if self.has_attribute?(:index) && approval_flow
  end
end
