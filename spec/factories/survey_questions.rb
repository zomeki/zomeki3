FactoryGirl.define do
  factory :survey_question_1, :class => 'Survey::Question' do
    association :form, :factory => :survey_form_1
    title 'アンケートの質問その１'
    sort_no 10
  end
end
