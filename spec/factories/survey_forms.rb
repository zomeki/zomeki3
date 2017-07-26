FactoryGirl.define do
  factory :survey_form, class: 'Survey::Form' do
    association :content, factory: :survey_content_form
    state 'public'
    sequence(:name) {|n| "form#{n}" }
    sequence(:title) {|n| "アンケートのフォームその#{n}" }
    sequence(:sort_no) {|n| n * 10 }
    summary { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    receipt { Faker::Lorem.sentence }
    confirmation true
    sitemap_state 'visible'
    index_link 'visible'
  end
end
