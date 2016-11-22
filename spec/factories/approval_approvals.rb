FactoryGirl.define do
  factory :approval_approval, class: 'Approval::Approval' do
    association :approval_flow, factory: :approval_approval_flow
    index 0
    approval_type 'fix'
  end
end
