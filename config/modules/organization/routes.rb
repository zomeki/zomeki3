ZomekiCMS::Application.routes.draw do
  mod = 'organization'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources :groups, :only => [:index, :show, :edit, :update],
      :controller => 'admin/groups',
      :path       => ':content/groups'
    resources :groups, :only => [:index, :show, :edit, :update],
      :controller => 'admin/groups',
      :path       => ':content/groups/:parent/groups',
      :as         => nil

    ## nodes
    resources :node_groups,
      :controller => 'admin/node/groups',
      :path       => ':parent/node_groups'

    ## pieces
#    resources :piece_groups, # Somehow doesn't work
    resources :piece_all_groups,
      :controller => 'admin/piece/all_groups'
    resources :piece_categorized_docs,
      :controller => 'admin/piece/categorized_docs'
    resources :piece_business_outlines,
      :controller => 'admin/piece/business_outlines'
    resources :piece_contact_informations,
      :controller => 'admin/piece/contact_informations'
    resources :piece_outlines,
      :controller => 'admin/piece/outlines'
  end

  ## public
  scope "_public/#{mod}", :module => mod do
    get 'node_groups(/index)' => 'public/node/groups#index'
  end
  scope "_public/#{mod}", :module => mod do
    get 'node_groups/*group_names/:filename_base' => 'public/node/groups#show'
    get 'node_groups/*group_names' => 'public/node/groups#show'
  end
end
