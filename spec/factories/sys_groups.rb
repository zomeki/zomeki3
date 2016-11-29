FactoryGirl.define do
  factory :sys_group, class: 'Sys::Group' do
    state 'enabled'
    web_state 'closed'
    parent_id 1
    level_no 2
    sequence(:code) {|n| '%03d' % n }
    sort_no 2
    layout_id nil
    ldap 0
    ldap_version nil
    sequence(:name) {|n| "組織#{n}" }
    sequence(:name_en) {|n| "org#{n}" }
    tel nil
    outline_uri nil
    email nil
    fax nil
    address nil
    note nil
    tel_attend nil

    trait :root do
      id 1
      parent_id 0
      level_no 1
      code 'root'
      sort_no 1
      name 'ルート'
      name_en 'root'
    end

    before(:create) do |group|
      attributes = attributes_for(:sys_group, :root)
      next if group.id == attributes[:id] || Sys::Group.find_by(id: attributes[:id])
      create(:sys_group, :root)
    end
  end
end
