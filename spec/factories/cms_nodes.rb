FactoryGirl.define do
  factory :cms_node, class: 'Cms::Node' do
    concept nil
    association :site, factory: :cms_site
    state 'public'
    recognized_at nil
    published_at { Faker::Time.backward(1.year) }
    parent_id 0
    route_id 0
    content_id nil
    model 'Cms::Directory'
    directory 1
    layout_id nil
    name '/'
    sequence(:title) {|n| "ノードタイトル#{n}" }
    body nil
    mobile_title nil
    mobile_body nil
    sitemap_state 'visible'
    sitemap_sort_no nil

    trait :page do
      model 'Cms::Page'
      directory 0
      name 'index.html'
      sequence(:body) {|n| "ノード#{n}" }
    end
  end
end
