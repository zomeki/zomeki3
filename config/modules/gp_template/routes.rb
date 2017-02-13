ZomekiCMS::Application.routes.draw do
  mod = 'gp_template'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/c:concept", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources(:templates,
      :controller => 'admin/templates',
      :path       => ':content/templates') do
      resources :items,
        :controller => 'admin/items'
      resources :forms,
        :controller => 'admin/forms' do
        collection do
          post :build
          put :build
        end
      end
    end
  end
end
