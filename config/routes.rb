JabberCTS::Application.routes.draw do
  devise_for :users

  root :to => 'rooms#index'
  get "ejabberd/commit"
  get "ejabberd/sync", as: 'ejabberd_sync'
  get "statistics/income", as: 'statistics_income'
  get 'i18n/datatable'
  get 'public_activity/index', as: 'public_activity'
  get 'rooms/transfer', as: 'transfer_room'
  resources :users
  resources :rooms
  resources :money_transfers
end
