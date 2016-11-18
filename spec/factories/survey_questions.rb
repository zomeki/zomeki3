FactoryGirl.define do
  factory :survey_question, class: 'Survey::Question' do
    association :form, factory: :survey_form
    state 'public'
    sequence(:title) {|n| "アンケートの質問その#{n}" }
    description { "#{title}の説明" }
    form_type 'text_field'
    form_options ''
    required true
    style_attribute 'background-color: #f00'
    sequence(:sort_no) {|n| n * 10 }
    form_text_max_length 30
  end
end
