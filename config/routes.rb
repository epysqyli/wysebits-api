Rails.application.routes.draw do
  scope path: '/api' do
    post '/login', to: 'authentication#authenticate'
    get '/logout', to: 'authentication#logout'
    get '/logged_in', to: 'authentication#logged_in'
    post '/signup', to: 'users#create'

    get '/users/:id/following', to: 'users#following'
    get '/users/:id/followers', to: 'users#followers'

    post '/users/:id/follow', to: 'users#add_following'
    post '/users/:id/unfollow', to: 'users#remove_following'

    get '/users/:id/fav_books', to: 'users#fav_books'
    post '/users/:id/fav_books/:book_id', to: 'users#add_to_fav_books'
    delete '/users/:id/fav_books/:book_id', to: 'users#remove_from_fav_books'

    get '/users/:id/fav_tile_entries', to: 'users#fav_tile_entries'
    post '/users/:id/fav_tile_entries/:tile_entry_id', to: 'users#add_to_fav_tile_entries'
    delete '/users/:id/fav_tile_entries/:tile_entry_id', to: 'users#remove_from_fav_tile_entries'

    get '/users/:id/upvoted_entries', to: 'users#upvoted_entries'
    get '/users/:id/downvoted_entries', to: 'users#downvoted_entries'
    post '/users/:id/tile_entries/:tile_entry_id/upvote', to: 'users#upvote'
    post '/users/:id/tile_entries/:tile_entry_id/downvote', to: 'users#downvote'

    get '/all_book_tiles', to: 'book_tiles#tiles_index'
    get '/top_tiles', to: 'tile_entries#top_tiles'
    get '/all_tiles_from_book/:id', to: 'books#tiles'

    resources :categories, only: :index
    get '/categories/:slug/books', to: 'categories#books'

    resources :books
    get '/books/:id/tile_entries', to: 'books#tile_entries'
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
