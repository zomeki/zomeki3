FactoryGirl.define do
  factory :survey_form_answer, class: 'Survey::FormAnswer' do
    association :form, factory: :survey_form
    answered_url { Faker::Internet.url }
    remote_addr { Faker::Internet.ip_v4_address }
    user_agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:49.0) Gecko/20100101 Firefox/49.0'
    sequence(:answered_url_title) {|n| "とあるページ#{n}" }
  end
end
