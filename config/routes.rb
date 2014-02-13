JabberCTS::Application.routes.draw do
  devise_for :users

  

  #root :to => 'rooms#index'
  authenticated :user do
    root :to => 'rooms#index', :as => :authenticated_root
    get "ejabberd/sync", as: 'ejabberd_sync'

  get "statistics/income", as: 'statistics_income'

  get 'i18n/datatable'

  get 'public_activity/index', as: 'public_activity'

  resources :users

  get 'rooms/transfer', as: 'transfer_room'
  resources :rooms

  resources :money_transfers
  end

  root :to => redirect('/users/sign_in')
end
