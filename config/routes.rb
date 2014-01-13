JabberCTS::Application.routes.draw do
  get 'i18n/datatable'

  get 'public_activity/index', as: 'public_activity'

  resources :users
  get 'users/home'

  resources :rooms

  resources :money_transfers

  root :to => 'rooms#index'
end
