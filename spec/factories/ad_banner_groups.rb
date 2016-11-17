FactoryGirl.define do
  factory :ad_banner_group, class: 'AdBanner::Group' do
    association :content, factory: :ad_banner_content_banner
    sequence(:name) {|n| "banner_group_#{n}" }
    sequence(:title) {|n| "バナーグループ#{n}" }
    sequence(:sort_no) {|n| n * 10 }
  end
end
