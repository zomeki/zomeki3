ZomekiCMS::Application.routes.draw do
  mod = 'gp_article'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources(:docs,
      :controller => 'admin/docs',
      :path       => ':content/docs') do
      get 'file_contents/(*path)' => 'admin/docs/files#content'
      member do
        post :approve
        post :passback
        post :pullback
        post :publish
        get  :select
      end
    end
    resources :related_docs,
      :controller => 'admin/related_docs', :only => [:show]

    ## nodes
    resources :node_docs,
      :controller => 'admin/node/docs',
      :path       => ':parent/node_docs'
    resources :node_archives,
      :controller => 'admin/node/archives',
      :path       => ':parent/node_archives'
    resources :node_search_docs,
      :controller => 'admin/node/search_docs',
      :path       => ':parent/node_search_docs'

    ## pieces
    resources :piece_docs,
      :controller => 'admin/piece/docs'
    resources(:piece_recent_tabs,
      :controller => 'admin/piece/recent_tabs') do
      resources :tabs,
        :controller => 'admin/piece/recent_tabs/tabs'
    end
    resources :piece_monthly_archives,
      :controller => 'admin/piece/monthly_archives'
    resources :piece_archives,
      :controller => 'admin/piece/archives'
    resources :piece_search_docs,
      :controller => 'admin/piece/search_docs'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    get 'node_docs(/(index))' => 'public/node/docs#index'
    get 'node_docs/:name/preview/:id/file_contents/(*path)' => 'public/node/docs#file_content'
    get 'node_docs/:name/preview/:id/qrcode.:extname' => 'public/node/docs#qrcode'
    get 'node_docs/:name/preview/:id(/(:filename_base.:format))' => 'public/node/docs#show'
    get 'node_docs/:name/file_contents/(*path)' => 'public/node/docs#file_content'
    get 'node_docs/:name/qrcode.:extname' => 'public/node/docs#qrcode'
    get 'node_docs/:name(/(:filename_base.:format))' => 'public/node/docs#show'
    get 'node_archives/:year(/(index))' => 'public/node/archives#index'
    get 'node_archives/:year/:month(/(index))' => 'public/node/archives#index'
    get 'node_search_docs(/(index))' => 'public/node/search_docs#index'
  end
end
