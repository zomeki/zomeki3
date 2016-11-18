FactoryGirl.define do
  factory :cms_content, class: 'Cms::Content' do
    site_id { concept.site_id }
    association :concept, factory: :cms_concept
    state 'public'
    model 'GpArticle::Doc'
    sequence(:name) {|n| "記事#{n}" }
    xml_properties nil
    sequence(:note) {|n| "#{name}のメモ" }
    sequence(:code) {|n| "ARTICLE#{n}" }
    sequence(:sort_no) {|n| n * 10 }

    trait :map_marker do
      model 'Map::Marker'
      sequence(:name) {|n| "地図#{n}" }
      sequence(:code) {|n| "MAP#{n}" }
    end

    trait :ad_banner_banner do
      model 'AdBanner::Banner'
      sequence(:name) {|n| "広告バナー#{n}" }
      sequence(:code) {|n| "AD#{n}" }
    end
  end
end
