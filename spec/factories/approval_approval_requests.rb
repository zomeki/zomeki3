FactoryGirl.define do
  factory :approval_approval_request, class: 'Approval::ApprovalRequest' do
    association :requester, factory: :sys_user
    association :approval_flow, factory: :approval_approval_flow
    association :approvable, factory: :survey_form
    current_index 0
    select_assignments nil
  end
end
