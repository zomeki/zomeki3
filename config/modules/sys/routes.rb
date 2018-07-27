ZomekiCMS::Application.routes.draw do
  mod = "sys"

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    get "tests" => "admin/tests#index",
      :as => :tests
    match "tests_mail" => "admin/tests/mail#index",
      :as => :tests_mail, via: [:get, :post]
    match "tests_link_check" => "admin/tests/link_check#index",
      :as => :tests_link_check, via: [:get, :post]

    match "storage_files(/*path)" => "admin/storage_files#index",
      as: :storage_files, format: false, via: [:get, :post, :put, :patch, :delete]

    resources :settings,
      :controller  => "admin/settings"
    resources :maintenances,
      :controller  => "admin/maintenances"
    resources :messages,
      :controller  => "admin/messages"
    resources :languages,
      :controller  => "admin/languages"
    resources :ldap_groups,
      :controller  => "admin/ldap_groups",
      :path        => ":parent/ldap_groups"
    resources :ldap_users,
      :controller  => "admin/ldap_users",
      :path        => ":parent/ldap_users"
    resources :ldap_synchros,
      :controller  => "admin/ldap_synchros" do
        member do
          get  :synchronize
          post :synchronize
        end
      end
    resources :kana_dictionaries,
      :controller  => "admin/kana_dictionaries" do
        collection do
          get  :make
          post :make
        end
      end
    resources :users,
      :controller  => "admin/users"
    resources :groups,
      :controller  => "admin/groups",
      :path        => ":parent/groups"
    resources :group_users,
      :controller  => "admin/group_users",
      :path        => ":parent/group_users"
    resources :export_groups,
      :controller  => "admin/groups/export" do
        collection do
          get  :export
          post :export
        end
      end
    resources :import_groups,
      :controller  => "admin/groups/import" do
        collection do
          get  :import
          post :import
        end
      end
    resources :role_names,
      :controller  => "admin/role_names"
    resources :object_privileges,
      :controller  => "admin/object_privileges",
      :path        => ":parent/object_privileges"
    resources :inline_files,
      :controller  => "admin/inline/files",
      :path        => ":content/:parent/inline_files" do
        member do
          get :content, :path => 'file_contents/(*path)'
          get :download
          get :crop
          post :crop
        end
        collection do
          get :view
        end
      end
    resources :operation_logs,
      :controller => "admin/operation_logs"
    resources :processes,
      :controller  => "admin/processes"
    resources :process_logs,
      :controller => "admin/process_logs"
    resources :plugins,
      :controller => "admin/plugins" do
        collection do
          get :restart
        end
      end
    resources :users_sessions,
      :controller => "admin/users_sessions"
    resources :publishers,
      :controller => "admin/publishers"
    resources :bookmarks,
      :controller  => "admin/bookmarks",
      :path        => ":parent/bookmarks"

    resources :reorg_groups,
      :controller  => "admin/reorg/groups",
      :path        => ":parent/reorg/groups"
    resources :reorg_group_users,
      :controller  => "admin/reorg/group_users",
      :path        => ":parent/reorg/group_users"
    resources :reorg_schedules,
      :controller  => "admin/reorg/schedules",
      :path        => ":parent/reorg/schedules"
    resources :reorg_runners,
      :controller  => "admin/reorg/runners",
      :path        => ":parent/reorg/runners" do
        collection do
          post :init, :exec, :clear
        end
    end
  end

  get "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}/:parent/inline_files/files/:name.:format" => 'sys/admin/inline/files#download'
end
