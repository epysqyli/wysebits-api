Rails.application.routes.draw do
  post 'authenticate', to: 'authentication#authenticate'

  resources :users do
    resources :book_tiles
  end

  get '/all_book_tiles', to: 'book_tiles#tiles_index'

  resources :book_tiles do
    resources :tile_entries
  end

  resources :tile_entries do
    resources :comments
  end

  resources :comments do
    resources :comments
  end
end
