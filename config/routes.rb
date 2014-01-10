JabberCTS::Application.routes.draw do
  get 'i18n/datatable'

  get 'public_activity/index', as: 'public_activity'

  resources :users
  get 'users/home'

  resources :contracts

  resources :money_transfers

  root :to => 'contracts#index'
end
