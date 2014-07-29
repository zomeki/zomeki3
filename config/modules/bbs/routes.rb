CmsCMS::Application.routes.draw do
  mod = "bbs"

  ## admin
  scope "#{CmsCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :items,
      :controller  => "admin/items",
      :path        => ":content/items"

    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller  => "admin/content/settings",
      :path        => ":content/content_settings"

    ## node
    resources :node_threads,
      :controller  => "admin/node/threads",
      :path        => ":parent/node_threads"

    ## piece
    resources :piece_recent_items,
      :controller  => "admin/piece/recent_items"
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "node_threads/(index.:format)" => "public/node/threads#index", via: [:get, :post]
    get "node_threads/new" => "public/node/threads#new"
    get "node_threads/delete" => "public/node/threads#delete"
    match "node_threads/:thread/(index.:format)" => "public/node/threads#show", via: [:get, :post]
  end
end
