Rails.application.routes.draw do
  post 'authenticate', to: 'authentication#authenticate'

  get '/all_book_tiles', to: 'book_tiles#tiles_index'
  get '/all_tiles_from_book/:id', to: 'books#tiles'

  post '/follow', to: 'users#add_following'
  post '/unfollow', to: 'users#remove_following'

  # # user login and signup to be defined later
  # post '/login', to: 'authentication#authenticate'
  # post '/signup', to: 'users#create'

  resources :users, only: :nil do
    resources :book_tiles
  end

  resources :book_tiles, only: :nil do
    resources :tile_entries
  end

  resources :tile_entries, only: %i[show] do
    resources :comments
  end

  resources :comments, only: :nil do
    resources :comments
  end
end
