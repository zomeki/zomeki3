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
    a = assignments.group_by(&:or_group_id).map { |_, assigns| assigns.map(&:user_label).join(" or ") }
    if approval_type_select?
      (a.size > 1) ? "[#{a.map{|aa| aa =~ / or / ? "（#{aa}）" : aa }.join(' or ')}]" : a.join
    else
      a.join(" and ")
    end
  end

  private

  def set_defaults
    self.approval_type ||= TYPE_OPTIONS.first.last if self.has_attribute?(:approval_type)
    self.index ||= approval_flow.approvals.count if self.has_attribute?(:index)
  end
end
