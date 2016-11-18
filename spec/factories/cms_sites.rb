FactoryGirl.define do
  factory :cms_site, class: 'Cms::Site' do
    state 'public'
    sequence(:name) {|n| "サイト#{n}" }
    sequence(:full_uri) {|n| "http://www#{n}.example.com/" }
    sequence(:mobile_full_uri) {|n| "http://m#{n}.example.com/" }
    node_id nil
    related_site ''
    map_key nil
    portal_group_state 'visible'
    portal_group_id nil
    portal_category_ids nil
    portal_business_ids nil
    portal_attribute_ids nil
    portal_area_ids nil
    body ''
    site_image_id nil
    og_type ''
    og_title ''
    og_description ''
    og_image ''
    smart_phone_publication 'no'
    spp_target 'only_top'
    google_map_api_key ''
    admin_full_uri nil

    trait :first do
      id 1
      name 'ひとつめのサイト'
      full_uri 'http://first.example.com/'
    end

    trait :second do
      id 2
      name 'ふたつめのサイト'
      full_uri 'http://second.example.com/'
    end

    trait :third do
      id 3
      name 'みっつめのサイト'
      full_uri 'http://third.example.com/'
    end
  end
end
