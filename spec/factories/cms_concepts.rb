FactoryGirl.define do
  factory :cms_concept, class: 'Cms::Concept' do
    parent_id 0
    site_id { create(:cms_site).id }
    state 'public'
    level_no 1
    sequence(:sort_no) {|n| n * 10 }
    sequence(:name) {|n| "コンセプト#{n}" }
  end
end
