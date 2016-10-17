ZomekiCMS::Application.routes.draw do
  mod = "cms"

  get "/_preview/:site/(*path)" => "cms/admin/preview#index",
    :as => :cms_preview, :defaults => { :concept => nil }
  match  "/_ssl/:site/(*path)" => "cms/public/common_ssl#index",
    :as => :cms_common_ssl, :defaults => { :concept => nil }, :via => [:get, :post]

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :navi_concepts,
      :controller  => "admin/navi/concepts"
    resources :navi_sites,
      :controller  => "admin/navi/sites"
      # :as => :cms_navi_concepts

    resources :tests,
      :controller  => "admin/tests"
    resources :concepts,
      :controller  => "admin/concepts",
      :path        => ":parent/concepts" do
        collection do
          get  :layouts
          post :layouts
        end
      end
    resources :sites,
      :controller  => "admin/sites" do
        member do
          get :show_portal
          get :hide_portal
        end
      end
    resources :site_basic_auth_users,
      :controller  => "admin/site/basic_auth_users",
      :path        => ":site/basic_auth_users" do
        collection do
          get :enable_auth
          get :disable_auth
        end
      end
    resources :site_settings,
      :controller  => "admin/site/settings",
      :path        => ":site/settings"
    resources :kana_dictionaries,
      :controller  => "admin/kana_dictionaries" do
        collection do
          get  :make
          post :make
          get  :test
          post :test
        end
      end
    resources :emergencies,
      :controller  => "admin/emergencies" do
        member do
          get :change
        end
      end
  end

  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod do
    post 'tool_rebuild_contents' => 'admin/tool/rebuild#rebuild_contents'
    post 'tool_rebuild_nodes' => 'admin/tool/rebuild#rebuild_nodes'
    match 'tool_rebuild' => 'admin/tool/rebuild#index', as: 'tool_rebuild', via: [:get, :post]
    match 'tool_search' => 'admin/tool/search#index', as: 'tool_search', via: [:get, :post]
    match 'tool_link_check' => 'admin/tool/link_check#index', as: 'tool_link_check', via: [:get, :post]
    match "tool_export"  => "admin/tool/export#index", via: [:get, :post]
    match "tool_import"  => "admin/tool/import#index", via: [:get, :post]
  end

  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    match "stylesheets/(*path)" => "admin/stylesheets#index",
      :as => :stylesheets, :format => false, via: [:get, :post, :put]
    resources :contents,
      :controller  => "admin/contents"
    resources :nodes,
      :controller  => "admin/nodes",
      :path        => ":parent/nodes" do
        collection do
          get  :search
          get  :content_options
          get  :model_options
        end
      end
    resources :layouts,
      :controller  => "admin/layouts"
    resources :pieces,
      :controller  => "admin/pieces" do
        collection do
          get  :content_options
          get  :model_options
        end
      end
    resources :data_texts,
      :controller  => "admin/data/texts"
    resources :data_files,
      :controller  => "admin/data/files",
      :path        => ":parent/data_files" do
        member do
          get :download
        end
      end
    resources :data_file_nodes,
      :controller  => "admin/data/file_nodes",
      :path        => ":parent/data_file_nodes"
    resources :inline_data_files,
      :controller  => "admin/inline/data_files",
      :path        => ":parent/inline_data_files" do
        member do
          get :download
        end
      end
    resources :inline_data_file_nodes,
      :controller  => "admin/inline/data_file_nodes",
      :path        => ":parent/inline_data_file_nodes"

    ## node
    resources :node_directories,
      :controller  => "admin/node/directories",
      :path        => ":parent/node_directories"
    resources :node_pages,
      :controller  => "admin/node/pages",
      :path        => ":parent/node_pages"
    resources :node_sitemaps,
      :controller  => "admin/node/sitemaps",
      :path        => ":parent/node_sitemaps"

    ## piece
    resources :piece_frees,
      :controller  => "admin/piece/frees"
    resources :piece_page_titles,
      :controller  => "admin/piece/page_titles"
    resources :piece_bread_crumbs,
      :controller  => "admin/piece/bread_crumbs"
    resources :piece_links,
      :controller  => "admin/piece/links"
    resources :piece_link_items,
      :controller  => "admin/piece/link_items",
      :path        => ":piece/piece_link_items"
    resources :piece_sns_parts,
      :controller  => "admin/piece/sns_parts"
    resources(:piece_pickup_docs,
      :controller => 'admin/piece/pickup_docs') do
      resources :docs,
        :controller => 'admin/piece/pickup_docs/docs'
    end
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    get "layouts/:id/:file.:format" => "public/layouts#index",
      :as => nil
    get "node_pages/"    => "public/node/pages#index",
      :as => nil
    get "node_sitemaps/" => "public/node/sitemaps#index",
      :as => nil
  end
end
