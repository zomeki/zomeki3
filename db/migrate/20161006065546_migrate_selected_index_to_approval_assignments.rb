class MigrateSelectedIndexToApprovalAssignments < ActiveRecord::Migration
  def up
    Approval::ApprovalRequest.find_each do |request|
      next if request.select_assignments.blank?
      assignments = YAML.load(request.select_assignments)
      assignments.each do |key, uid_str|
        approval_id = key.scan(/approval_(\d+)/).flatten.first.to_i
        approval = Approval::Approval.find_by(id: approval_id)
        next unless approval
        uid_str.split(' ').each_with_index do |uids, i|
          uids.split(',').each do |uid|
            request.selected_assignments.create(user_id: uid, selected_index: approval.index, or_group_id: i)
          end
        end
      end
    end
  end
end
