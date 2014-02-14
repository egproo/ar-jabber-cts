JabberCTS::Application.routes.draw do
  devise_for :users

  # authenticated :user do
  #   root :to => 'rooms#index', :as => :authenticated_root
  #   get "ejabberd/sync", as: 'ejabberd_sync'
  #   get "statistics/income", as: 'statistics_income'
  #   get 'i18n/datatable'
  #   get 'public_activity/index', as: 'public_activity'
  #   get 'rooms/transfer', as: 'transfer_room'
  #   resources :users
  #   resources :rooms
  #   resources :money_transfers
  # end

  # root :to => redirect('/users/sign_in')

  root :to => 'rooms#index'
  get "ejabberd/sync", as: 'ejabberd_sync'
  get "statistics/income", as: 'statistics_income'
  get 'i18n/datatable'
  get 'public_activity/index', as: 'public_activity'
  get 'rooms/transfer', as: 'transfer_room'
  resources :users
  resources :rooms
  resources :money_transfers
end
