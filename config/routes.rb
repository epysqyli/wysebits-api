Rails.application.routes.draw do
  scope path: '/api' do
    # auth
    post '/login', to: 'authentication#authenticate'
    get '/logout', to: 'authentication#logout'
    get '/logged_in', to: 'authentication#logged_in'
    post '/signup', to: 'users#create'

    # user relationships
    get '/users/:id/following', to: 'users#following'
    get '/users/:id/unpaged_following', to: 'users#unpaged_following'
    get '/users/:id/followers', to: 'users#followers'
    get '/users/:id/unpaged_followers', to: 'users#unpaged_followers'
    post '/users/:id/follow/:other_user_id', to: 'users#add_following'
    post '/users/:id/unfollow/:other_user_id', to: 'users#remove_following'

    # user fav books
    get '/users/:id/fav_books', to: 'users#fav_books'
    post '/users/:id/fav_books/:book_id', to: 'users#add_to_fav_books'
    delete '/users/:id/fav_books/:book_id', to: 'users#remove_from_fav_books'

    # user fav entries
    get '/users/:id/fav_tile_entries', to: 'users#fav_tile_entries'
    post '/users/:id/fav_tile_entries/:tile_entry_id', to: 'users#add_to_fav_tile_entries'
    delete '/users/:id/fav_tile_entries/:tile_entry_id', to: 'users#remove_from_fav_tile_entries'

    # user upvoting / downvoting entries
    get '/users/:id/upvoted_entries', to: 'users#upvoted_entries'
    get '/users/:id/downvoted_entries', to: 'users#downvoted_entries'
    post '/users/:id/tile_entries/:tile_entry_id/upvote', to: 'users#upvote'
    post '/users/:id/tile_entries/:tile_entry_id/remove_upvote', to: 'users#remove_upvote'
    post '/users/:id/tile_entries/:tile_entry_id/downvote', to: 'users#downvote'
    post '/users/:id/tile_entries/:tile_entry_id/remove_downvote', to: 'users#remove_downvote'

    # top tiles? to be checked
    get '/top_tiles', to: 'tile_entries#top_tiles'
    get '/all_tiles_from_book/:id', to: 'books#tiles'

    # resources
    get '/users/:username', to: 'users#show', constraints: { username: /[0-z.]+/ }

    resources :categories, only: :index
    get '/categories/:slug/books', to: 'categories#books'

    resources :books
    get '/books/:id/tile_entries', to: 'books#tile_entries'
    post '/search/books', to: 'search_requests#search_books'

    resources :users, only: :nil do
      resources :book_tiles
    end

    get '/users/:user_id/book_tiles_no_pagy', to: 'book_tiles#index_no_pagy'
    get '/users/:user_id/temp_book_tiles', to: 'book_tiles#index_temp_entries'
    get '/users/:user_id/book_tiles/:book_id/is_available', to: 'book_tiles#available?'

    resources :book_tiles, only: :nil do
      resources :tile_entries
      resources :temporary_entries
    end

    get '/users/:user_id/tile_entries/all_user_entries', to: 'tile_entries#all_user_entries'

    resources :tile_entries, only: %i[show] do
      resources :comments
    end

    resources :comments, only: :nil do
      resources :comments
    end
  end
end
