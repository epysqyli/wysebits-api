Rails.application.routes.draw do
  post 'authenticate', to: 'authentication#authenticate'

  get '/all_book_tiles', to: 'book_tiles#tiles_index'

  # limit routes accordingly with only: :actions
  resources :users do
    resources :book_tiles
  end

  resources :book_tiles do
    resources :tile_entries
  end

  resources :tile_entries, only: %i[show] do
    resources :comments
  end

  resources :comments do
    resources :comments
  end
end
