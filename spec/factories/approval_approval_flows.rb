FactoryGirl.define do
  factory :approval_approval_flow, class: 'Approval::ApprovalFlow' do
    association :content, factory: :approval_content_approval_flow
    sequence(:title) {|n| "承認フロー#{n}" }
    association :group, factory: :sys_group
    sequence(:sort_no) {|n| n * 10 }
  end
end
