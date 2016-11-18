FactoryGirl.define do
  factory :survey_content_form, class: 'Survey::Content::Form' do
    site_id { concept.site_id }
    association :concept, factory: :cms_concept
    state 'public'
    model 'Survey::Form'
    sequence(:name) {|n| "アンケート#{n}" }
    xml_properties nil
    sequence(:note) {|n| "#{name}のメモ" }
    sequence(:code) {|n| "SF#{n}" }
    sequence(:sort_no) {|n| n * 10 }
  end
end
