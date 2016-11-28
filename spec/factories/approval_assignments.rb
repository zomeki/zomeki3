FactoryGirl.define do
  factory :approval_assignment, class: 'Approval::Assignment' do
    association :user, factory: :sys_user
    approved_at nil
    or_group_id nil
    selected_index nil

    after :build do |assignment|
      assignment.assignable = create(:approval_approval_flow).approvals.build(attributes_for :approval_approval) unless assignment.assignable
    end
  end
end
