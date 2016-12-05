ZomekiCMS::Application.routes.draw do
  mod = 'relation'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources :docs, :only => [:index],
      :controller => 'admin/docs',
      :path       => ':content/docs'

  end
end
