Rails.application.routes.draw do
  scope path: '/api' do
    post '/login', to: 'authentication#authenticate'
    get '/logout', to: 'authentication#logout'
    get '/logged_in', to: 'authentication#logged_in'
    post '/signup', to: 'users#create'

    post '/follow', to: 'users#add_following'
    post '/unfollow', to: 'users#remove_following'

    get '/users/:id/fav_books', to: 'users#fav_books'
    get '/users/:id/fav_tile_entries', to: 'users#fav_tile_entries'

    get '/all_book_tiles', to: 'book_tiles#tiles_index'
    get '/top_tiles', to: 'tile_entries#top_tiles'
    get '/all_tiles_from_book/:id', to: 'books#tiles'

    resources :categories, only: :index

    resources :books
    post '/search/books', to: 'search_requests#search_books'

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
end
