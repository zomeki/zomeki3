FactoryGirl.define do
  factory :approval_approval_request_history, class: 'Approval::ApprovalRequestHistory' do
    association :request, factory: :approval_approval_request
    association :operator, factory: :sys_user
    reason '承認履歴の理由'
    comment '承認履歴のコメント'
  end
end
