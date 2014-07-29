CmsCMS::Application.routes.draw do
  mod = "portal_group"

  ## admin
  scope "#{CmsCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :groups,
      :controller  => "admin/groups",
      :path        => ":content/groups" do
        collection do
          get  :categories
          get  :businesses
          get  :attributes
          get  :areas
        end
      end
    resources :categories,
      :controller  => "admin/categories",
      :path        => ":content/:parent/categories"
    resources :businesses,
      :controller  => "admin/businesses",
      :path        => ":content/:parent/businesses"
    resources :attributes,
      :controller  => "admin/attributes",
      :path        => ":content/attributes"
    resources :areas,
      :controller  => "admin/areas",
      :path        => ":content/:parent/areas"

    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path        => ":content/content_settings"

    ## node
    resources :node_recent_docs,
      :controller  => "admin/node/recent_docs",
      :path        => ":parent/node_recent_docs"
    resources :node_tag_docs,
      :controller  => "admin/node/tag_docs",
      :path        => ":parent/node_tag_docs"
    resources :node_categories,
      :controller  => "admin/node/categories",
      :path        => ":parent/node_categories"
    resources :node_businesses,
      :controller  => "admin/node/businesses",
      :path        => ":parent/node_businesses"
    resources :node_attributes,
      :controller  => "admin/node/attributes",
      :path        => ":parent/node_attributes"
    resources :node_areas,
      :controller  => "admin/node/areas",
      :path        => ":parent/node_areas"
    resources :node_sites,
      :controller  => "admin/node/sites",
      :path        => ":parent/node_sites"
    resources :node_site_categories,
      :controller  => "admin/node/site_categories",
      :path        => ":parent/node_site_categories"
    resources :node_site_businesses,
      :controller  => "admin/node/site_businesses",
      :path        => ":parent/node_site_businesses"
    resources :node_site_attributes,
      :controller  => "admin/node/site_attributes",
      :path        => ":parent/node_site_attributes"
    resources :node_site_areas,
      :controller  => "admin/node/site_areas",
      :path        => ":parent/node_site_areas"
    resources :node_threads,
      :controller  => "admin/node/threads",
      :path        => ":parent/node_threads"
    resources :node_tag_threads,
      :controller  => "admin/node/tag_threads",
      :path        => ":parent/node_tag_threads"
    resources :node_thread_categories,
      :controller  => "admin/node/thread_categories",
      :path        => ":parent/node_thread_categories"
    resources :node_thread_businesses,
      :controller  => "admin/node/thread_businesses",
      :path        => ":parent/node_thread_businesses"
    resources :node_thread_attributes,
      :controller  => "admin/node/thread_attributes",
      :path        => ":parent/node_thread_attributes"
    resources :node_thread_areas,
      :controller  => "admin/node/thread_areas",
      :path        => ":parent/node_thread_areas"

    ## piece
    resources :piece_recent_docs,
      :controller  => "admin/piece/recent_docs"
    resources :piece_recent_tabs,
      :controller  => "admin/piece/recent_tabs"
    resources :piece_recent_tab_tabs,
      :controller  => "admin/piece/recent_tab/tabs",
      :path        => ":piece/piece_recent_tab_tabs"
    resources :piece_calendars,
      :controller  => "admin/piece/calendars"
    resources :piece_categories,
      :controller  => "admin/piece/categories"
    resources :piece_businesses,
      :controller  => "admin/piece/businesses"
    resources :piece_attributes,
      :controller  => "admin/piece/attributes"
    resources :piece_areas,
      :controller  => "admin/piece/areas"
    resources :piece_recent_sites,
      :controller  => "admin/piece/recent_sites"
    resources :piece_site_categories,
      :controller  => "admin/piece/site_categories"
    resources :piece_site_businesses,
      :controller  => "admin/piece/site_businesses"
    resources :piece_site_attributes,
      :controller  => "admin/piece/site_attributes"
    resources :piece_site_areas,
      :controller  => "admin/piece/site_areas"
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    get "node_docs/index.:format"                        => "public/node/docs#index"
    get "node_recent_docs/index.:format"                 => "public/node/recent_docs#index"
    get "node_event_docs/:year/:month/index.:format"     => "public/node/event_docs#month"
    get "node_event_docs/index.:format"                  => "public/node/event_docs#month"
    get "node_tag_docs/index.:format"                    => "public/node/tag_docs#index"
    get "node_tag_docs/:tag"                             => "public/node/tag_docs#index"
    get "node_categories/:name/:attr/index.:format"      => "public/node/categories#show_attr"
    get "node_categories/:name/:file.:format"            => "public/node/categories#show"
    get "node_categories/index.:format"                  => "public/node/categories#index"
    get "node_businesses/:name/:attr/index.:format"      => "public/node/businesses#show_attr"
    get "node_businesses/:name/:file.:format"            => "public/node/businesses#show"
    get "node_businesses/index.:format"                  => "public/node/businesses#index"
    get "node_attributes/:name/:attr/index.:format"      => "public/node/attributes#show_attr"
    get "node_attributes/:name/:file.:format"            => "public/node/attributes#show"
    get "node_attributes/index.:format"                  => "public/node/attributes#index"
    get "node_areas/:name/:attr/index.:format"           => "public/node/areas#show_attr"
    get "node_areas/:name/:file.:format"                 => "public/node/areas#show"
    get "node_areas/index.:format"                       => "public/node/areas#index"
    get "node_sites/index.:format"                       => "public/node/sites#index"
    get "node_site_categories/:name/:attr/index.:format" => "public/node/site_categories#show_attr"
    get "node_site_categories/:name/:file.:format"       => "public/node/site_categories#show"
    get "node_site_categories/index.:format"             => "public/node/site_categories#index"
    get "node_site_businesses/:name/:attr/index.:format" => "public/node/site_businesses#show_attr"
    get "node_site_businesses/:name/:file.:format"       => "public/node/site_businesses#show"
    get "node_site_businesses/index.:format"             => "public/node/site_businesses#index"
    get "node_site_attributes/:name/:attr/index.:format" => "public/node/site_attributes#show_attr"
    get "node_site_attributes/:name/:file.:format"       => "public/node/site_attributes#show"
    get "node_site_attributes/index.:format"             => "public/node/site_attributes#index"
    get "node_site_areas/:name/:attr/index.:format"      => "public/node/site_areas#show_attr"
    get "node_site_areas/:name/:file.:format"            => "public/node/site_areas#show"
    get "node_site_areas/index.:format"                  => "public/node/site_areas#index"
    get "node_threads/index.:format"                     => "public/node/threads#index"
    get 'node_tag_threads/index.:format'                 => 'public/node/tag_threads#index'
    get 'node_tag_threads/:tag'                          => 'public/node/tag_threads#index'
    get "node_thread_categories/:name/:file.:format"     => "public/node/thread_categories#show"
    get "node_thread_categories/index.:format"           => "public/node/thread_categories#index"
    get "node_thread_businesses/:name/:file.:format"     => "public/node/thread_businesses#show"
    get "node_thread_businesses/index.:format"           => "public/node/thread_businesses#index"
    get "node_thread_attributes/:name/:file.:format"     => "public/node/thread_attributes#show"
    get "node_thread_attributes/index.:format"           => "public/node/thread_attributes#index"
    get "node_thread_areas/:name/:file.:format"          => "public/node/thread_areas#show"
    get "node_thread_areas/index.:format"                => "public/node/thread_areas#index"
  end
end
