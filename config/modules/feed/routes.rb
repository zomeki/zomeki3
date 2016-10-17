ZomekiCMS::Application.routes.draw do
  mod = 'feed'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources(:feeds,
      :controller => 'admin/feeds',
      :path       => ':content/feeds') do
      resources :entries,
        :controller => 'admin/entries'
    end

    ## nodes
    resources :node_feed_entries,
      :controller => 'admin/node/feed_entries',
      :path       => ':parent/node_feed_entries'

    ## pieces
    resources :piece_feed_entries,
      :controller => 'admin/piece/feed_entries'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    get 'node_feed_entries(/index.:format)' => 'public/node/feed_entries#index'
    get 'node_feed_entries/:file_base.:file_ext' => 'public/node/feed_entries#index'
    get 'node_feed_entries/:token' => 'public/node/feed_entries#index'
  end
end
