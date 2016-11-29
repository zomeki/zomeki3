FactoryGirl.define do
  factory :cms_site_belonging, class: 'Cms::SiteBelonging' do
    association :site, factory: :cms_site
    association :group, factory: :sys_group
  end
end
