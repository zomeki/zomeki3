Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # Common directory
  match '/_common(/*path)' => 'exception#index', via: :all

  # Themes directory
  match '/_themes(/*path)' => 'exception#index', via: :all

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

  # Files
  get "_files/*path"           => "cms/public/files#down"

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
