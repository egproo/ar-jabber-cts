JabberCTS::Application.routes.draw do
  get "statistics/income"

  get 'i18n/datatable'

  get 'public_activity/index', as: 'public_activity'

  resources :users

  get 'rooms/transfer', as: 'transfer_room'
  resources :rooms

  resources :money_transfers

  root :to => 'rooms#index'
end
