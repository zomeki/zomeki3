FactoryGirl.define do
  factory :sys_user, class: 'Sys::User' do
    state 'enabled'
    ldap 0
    ldap_version nil
    auth_no 2
    name { Faker::Name.name }
    name_en { l = Faker::Config.locale
              Faker::Config.locale = :en
              n = Faker::Name.name
              Faker::Config.locale = l
              n }
    sequence(:account) {|n| "user#{'%03d' % n}" }
    password { "#{account}pass" }
    email { Faker::Internet.safe_email account }
    remember_token nil
    remember_token_expires_at nil
    admin_creatable false
    site_creatable false
    reset_password_token nil
    reset_password_token_expires_at nil

    trait :system_admin do
      id 1
      auth_no 5
    end

    trait :site_admin do
      auth_no 5
    end
  end
end
