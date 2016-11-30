FactoryGirl.define do
  factory :ad_banner_content_banner, class: 'AdBanner::Content::Banner' do
    site_id { concept.site_id }
    association :concept, factory: :cms_concept
    state 'public'
    model 'AdBanner::Banner'
    sequence(:name) {|n| "広告バナー#{n}" }
    xml_properties nil
    sequence(:note) {|n| "広告バナー#{n}のメモ" }
    sequence(:code) {|n| "AD#{n}" }
    sequence(:sort_no) {|n| n * 10 }
  end
end
