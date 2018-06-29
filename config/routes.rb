Portrait::Application.routes.draw do
  resources :sites

  resources :users do
    member do
      get  'change_password' => 'users#change_password'
    end

    collection do
      get   'reset_password'
      post  'send_reset_password_email'
      patch 'update_password'
    end
  end

  root to: 'home#index'
end
