namespace :import do
  resource :github, only: [:create, :new], controller: :github do
    post :personal_access_token
    get :status
    get :callback
    get :jobs
  end

  resource :gitea, only: [:create, :new], controller: :gitea do
    post :personal_access_token
    get :status
    get :jobs
  end

  resource :doggohub, only: [:create], controller: :doggohub do
    get :status
    get :callback
    get :jobs
  end

  resource :bitbucket, only: [:create], controller: :bitbucket do
    get :status
    get :callback
    get :jobs
  end

  resource :google_code, only: [:create, :new], controller: :google_code do
    get :status
    post :callback
    get :jobs

    get   :new_user_map,    path: :user_map
    post  :create_user_map, path: :user_map
  end

  resource :fogbugz, only: [:create, :new], controller: :fogbugz do
    get :status
    post :callback
    get :jobs

    get   :new_user_map,    path: :user_map
    post  :create_user_map, path: :user_map
  end

  resource :doggohub_project, only: [:create, :new] do
    post :create
  end
end
