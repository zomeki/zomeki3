CmsCMS::Application.routes.draw do
  mod = 'public_bbs'

  ## admin
  scope "#{CmsCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources(:threads,
      :controller => 'admin/threads',
      :path       => ':content/threads') do
      get 'file_contents/:file.:format' => 'admin/threads/files#download'
      resources :files,
        :controller => 'admin/threads/files'
      resources(:responses,
        :controller => 'admin/responses') do
        get 'file_contents/:file.:format' => 'admin/responses/files#download'
        resources :files,
          :controller => 'admin/responses/files'
      end
    end
    resources :categories,
      :controller => 'admin/categories',
      :path       => ':content/:parent/categories'

    ## content
    resources :content_base,
      :controller => 'admin/content/base'
    resources :content_settings,
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## node
    resources :node_threads,
      :controller => 'admin/node/threads',
      :path       => ':parent/node_threads'
    resources :node_recent_threads,
      :controller => 'admin/node/recent_threads',
      :path       => ':parent/node_recent_threads'
    resources :node_tag_threads,
      :controller => 'admin/node/tag_threads',
      :path       => ':parent/node_tag_threads'
    resources :node_categories,
      :controller => 'admin/node/categories',
      :path       => ':parent/node_categories'

    ## piece
    resources :piece_categories,
      :controller => 'admin/piece/categories'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    get 'node_threads/index.:format' => 'public/node/threads#index'
    resources(:node_threads,
      :controller => 'public/node/threads') do
      get 'file_contents/:file.:format' => 'public/node/threads/files#download'
      resources :files,
        :controller => 'public/node/threads/files'
      resources(:responses,
        :controller => 'public/node/responses') do
        get 'file_contents/:file.:format' => 'public/node/responses/files#download'
        resources :files,
          :controller => 'public/node/responses/files'
      end
    end
    get 'node_recent_threads(/index.:format)' => 'public/node/recent_threads#index'
    get 'node_tag_threads/index.:format'      => 'public/node/tag_threads#index'
    get 'node_tag_threads/:tag'               => 'public/node/tag_threads#index'
    get 'node_categories/:name(/:file.:format)' => 'public/node/categories#show'
    get 'node_categories/index.:format'       => 'public/node/categories#index'
  end
end
