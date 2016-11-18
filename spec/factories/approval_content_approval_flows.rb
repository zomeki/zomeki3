FactoryGirl.define do
  factory :approval_content_approval_flow, class: 'Approval::Content::ApprovalFlow' do
    site_id { concept.site_id }
    association :concept, factory: :cms_concept
    state 'public'
    model 'Approval::ApprovalFlow'
    sequence(:name) {|n| "承認フロー#{n}" }
    xml_properties nil
    sequence(:note) {|n| "#{name}のメモ" }
    sequence(:code) {|n| "APPROVAL#{n}" }
    sequence(:sort_no) {|n| n * 10 }
  end
end
