ZomekiCMS::Application.routes.draw do
  mod = 'reception'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources(:courses,
      :controller => 'admin/courses',
      :path       => ':content/courses') do
      get "file_contents/(*path)" => "admin/courses/files#content"
      resources :opens,
        :controller => 'admin/opens' do
        resources :applicants,
          :controller => 'admin/applicants'
      end
    end

    ## nodes
    resources :node_courses,
      :controller => 'admin/node/courses',
      :path       => ':parent/node_courses'
    resources :node_categories,
      :controller => 'admin/node/categories',
      :path       => ':parent/node_categories'

    ## pieces
    resources :piece_courses,
      :controller => 'admin/piece/courses'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    # courses
    get 'node_courses(/index)' => 'public/node/courses#index'
    get 'node_courses/:name(/index)' => 'public/node/courses#show'
    get "node_courses/:name/file_contents/(*path)" => "public/node/courses/files#content"
    # applicants
    get 'node_courses/:name/applicants/new' => 'public/node/applicants#new'
    post 'node_courses/:name/applicants(/index)' => 'public/node/applicants#create'
    get 'node_courses/:name/applicants/:token/cancel' => 'public/node/applicants#cancel'
    patch 'node_courses/:name/applicants/:token/cancel' => 'public/node/applicants#cancel'
    # categories
    get 'node_courses/categories/:category_type_name/*category_names/:file.:format' => 'public/node/categories#index'
  end
end
