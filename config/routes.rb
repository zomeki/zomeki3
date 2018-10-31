Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Admin
  admin = ZomekiCMS::ADMIN_URL_PREFIX
  get admin => 'sys/admin/front#index', as: :admin_root
  match "#{admin}/login" => 'sys/admin/account#login', as: :admin_login, via: [:get, :post]
  get "#{admin}/logout" => 'sys/admin/account#logout', as: :admin_logout
  get "#{admin}/account" => 'sys/admin/account#info', as: :admin_account
  get "#{admin}/password_reminders/new" => 'sys/admin/account#new_password_reminder', as: :new_admin_password_reminder
  post "#{admin}/password_reminders" => 'sys/admin/account#create_password_reminder', as: :admin_password_reminders
  get "#{admin}/password/edit" => 'sys/admin/account#edit_password', as: :edit_admin_password
  put "#{admin}/password" => 'sys/admin/account#update_password', as: :admin_password
  get "#{admin}/redirect/:model/:id" => 'sys/admin/redirect#index'

  # Tool
  get "/_tools/captcha/index"  => "simple_captcha#index"
  get "/_tools/captcha/talk"   => "simple_captcha#talk"

  # Public
  get '_common(/*path)'     => 'cms/public/common#index', format: false
  get '_themes(/*path)'     => 'cms/public/themes#index', format: false
  get '_files(/:id/*path)'  => 'cms/public/files#index', format: false

  # Pieces
  get "_pieces(/:id/*path)"      => "cms/public/pieces#index"

  # Talking
  %w(_public _preview).each do |mode|
    get "#{mode}/*path.html.mp3"         => "cms/public/talk#down_mp3"
    get "#{mode}/*path.html.m3u"         => "cms/public/talk#down_m3u"
    get "#{mode}/*path.html.r.mp3"       => "cms/public/talk#down_mp3"
    get "#{mode}/*path.html.r.m3u"       => "cms/public/talk#down_m3u"
  end

  # Modules
  Dir.glob("#{Rails.root}/config/modules/**/routes.rb").each do |file|
    load file
  end

  # Engines
  Rails.application.config.x.engines.each do |engine|
    Dir["#{engine.root}/config/modules/**/routes.rb"].each do |file|
      load file
    end
    mount engine => "/#{ZomekiCMS::ADMIN_URL_PREFIX}/plugins/#{engine.engine_name}"
  end

  # Exception
  get "#{admin}/*path" => "cms/admin/exception#index"
  get "404.:format" => "cms/public/exception#index"
  get "*path"       => "cms/public/exception#index"
end
