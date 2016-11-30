FactoryGirl.define do
  factory :ad_banner_banner, class: 'AdBanner::Banner' do
    sequence(:name) {|n| "sample_picture_#{n}.jpg" }
    sequence(:title) {|n| "サンプル画像#{n}" }
    mime_type { Rack::Mime.mime_type '.jpg' }
    size { SecureRandom.random_number 5.megabytes }
    image_is 1
    image_width { SecureRandom.random_number 500 }
    image_height { SecureRandom.random_number 500 }
    content { group.content }
    association :group, factory: :ad_banner_group
    state 'public'
    sequence(:advertiser_name) {|n| "広告主株式会社#{n}" }
    advertiser_phone { Faker::PhoneNumber.phone_number }
    sequence(:advertiser_email) {|n| Faker::Internet.safe_email "ad#{n}" }
    advertiser_contact { Faker::Name.last_name }
    published_at { Faker::Time.backward(1.week) }
    closed_at { Faker::Time.forward(1.week) }
    url { Faker::Internet.url }
    sequence(:sort_no) {|n| n * 10 }
    token { Util::String::Token.generate_unique_token(AdBanner::Banner, :token) }
    target '_blank'
    site_id { content.try(:site_id) }
    thumb_width { SecureRandom.random_number 200 }
    thumb_height { SecureRandom.random_number 200 }
    thumb_size { SecureRandom.random_number 1.megabyte }

    trait :png do
      sequence(:name) {|n| "sample_picture_#{n}.png" }
      mime_type { Rack::Mime.mime_type '.png' }
    end

    trait :gif do
      sequence(:name) {|n| "sample_picture_#{n}.gif" }
      mime_type { Rack::Mime.mime_type '.gif' }
    end
  end
end
