## ---------------------------------------------------------
## sys

if @create_base
  first_group = Sys::Group.new(
    :parent_id => 0,
    :level_no  => 1,
    :sort_no   => 1,
    :state     => 'enabled',
    :web_state => 'closed',
    :ldap      => 0,
    :code      => "#{@code_prefix}root",
    :name      => 'トップ',
    :name_en   => "#{@code_prefix}top"
  )
  first_group.save(validate: false)
else
  first_group = Sys::Group.find(1)
end
cms_group = Sys::Group.new(
  :parent_id => first_group.id,
  :level_no  => 2,
  :sort_no   => 2,
  :state     => 'enabled',
  :web_state => 'closed',
  :ldap      => 0,
  :code      => "#{@code_prefix}001",
  :name      => 'ぞめき',
  :name_en   => 'cms'
)
cms_group.save(validate: false)

first_user = Sys::User.create!(
  :state    => 'enabled',
  :ldap     => 0,
  :auth_no  => 5,
  :name     => 'システム管理者',
  :account  => "#{@code_prefix}zomeki",
  :password => 'zomeki'
)

Sys::UsersGroup.create!(group: cms_group, user: first_user)

Core.user_group = cms_group
Core.user       = first_user

@site.groups << first_group
@site.groups << cms_group


if @create_base
  awa = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '阿波 ぞめき', name_en: 'awa zomeki', account: 'awa', password: 'awa')
  Sys::UsersGroup.create!(group: cms_group, user: awa)
  hachisuka = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 4, name: '蜂須賀 太郎', name_en: 'hachisuka taro', account: 'hachisuka', password: 'hachisuka')
  Sys::UsersGroup.create!(group: cms_group, user: hachisuka)
  ebisu = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '恵比寿 花子', name_en: 'ebisu hanako', account: 'ebisu', password: 'ebisu')
  Sys::UsersGroup.create!(group: cms_group, user: ebisu)
  ukiyo = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '浮世 蓮', name_en: 'ukiyo ren', account: 'ukiyo', password: 'ukiyo')
  Sys::UsersGroup.create!(group: cms_group, user: ukiyo)
  sasa = Sys::User.create!(state: 'enabled', ldap: 0, auth_no: 2, name: '笹 みやび', name_en: 'sasa miyabi', account: 'sasa', password: 'sasa')
  Sys::UsersGroup.create!(group: cms_group, user: sasa)
end
## ---------------------------------------------------------
## cms
if @create_base
  Sys::Language.create!(
    :state   => 'enabled',
    :sort_no => 1,
    :name    => 'Japanese',
    :title   => '日本語'
  )
end

puts 'Imported base data.'
