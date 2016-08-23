FactoryGirl.define do
  factory :survey_form_1, class: 'Survey::Form' do
    association :content, :factory => :survey_content_form_1
    name 'form1'
    title 'アンケートのフォームその1'
  end
  factory :survey_form_2, class: 'Survey::Form' do
    association :content, :factory => :survey_content_form_2
    name 'form2'
    title 'アンケートのフォームその2'
  end
end
