module Approval::Model::Rel::Approval
  extend ActiveSupport::Concern

  attr_accessor :in_approval_flow_ids, :in_approval_assignment_ids

  included do
    with_options if: -> { !in_approval_flow_ids.nil? && state_approvable? } do
      validate :validate_approval_requests
      after_save :save_approval_requests
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
