FactoryGirl.define do
  factory :survey_answer, class: 'Survey::Answer' do
    association :form_answer, factory: :survey_form_answer
    association :question, factory: :survey_question
    content { Faker::Lorem.paragraph }
  end
end
