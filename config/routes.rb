Rails.application.routes.draw do
  scope path: '/api' do
    # auth
    post '/login', to: 'authentication#authenticate'
    get '/logout', to: 'authentication#logout'
    get '/logged_in', to: 'authentication#logged_in'
    post '/signup', to: 'users#create'
    post '/confirm', to: 'users#confirm'

    # password routes
    post '/password/forgot', to: 'passwords#forgot'
    put '/password/reset', to: 'passwords#reset'
    put '/password/update', to: 'passwords#update'

    # user fields availability
    post '/users/username_available', to: 'users#username_available?'
    post '/users/email_address_available', to: 'users#email_address_available?'

    # user updates
    put '/users/update_username', to: 'users#update_username'
    post '/users/update_email', to: 'users#update_email'
    post '/users/confirm_email_update', to: 'users#confirm_email_update'

    # user avatar actions
    put '/users/:id/update_avatar', to: 'users#update_avatar'
    delete '/users/:id/delete_avatar', to: 'users#delete_avatar'

    # user relationships
    get '/users/:id/following', to: 'users#following'
    get '/users/:id/unpaged_following', to: 'users#unpaged_following'
    get '/users/:id/followers', to: 'users#followers'
    get '/users/:id/unpaged_followers', to: 'users#unpaged_followers'
    post '/users/:id/follow/:other_user_id', to: 'users#add_following'
    post '/users/:id/unfollow/:other_user_id', to: 'users#remove_following'

    # user fav books
    get '/users/:id/fav_books', to: 'users#fav_books'
    get '/users/:id/unpaged_fav_books', to: 'users#unpaged_fav_books'
    post '/users/:id/fav_books/:book_id', to: 'users#add_to_fav_books'
    delete '/users/:id/fav_books/:book_id', to: 'users#remove_from_fav_books'

    # user fav entries
    get '/users/:id/fav_tile_entries', to: 'users#fav_tile_entries'
    get '/users/:id/unpaged_fav_tile_entries', to: 'users#unpaged_fav_tile_entries'
    post '/users/:id/fav_tile_entries/:tile_entry_id', to: 'users#add_to_fav_tile_entries'
    delete '/users/:id/fav_tile_entries/:tile_entry_id', to: 'users#remove_from_fav_tile_entries'

    # user upvoting / downvoting entries
    get '/users/:id/upvoted_entries', to: 'users#upvoted_entries'
    get '/users/:id/downvoted_entries', to: 'users#downvoted_entries'
    post '/users/:id/tile_entries/:tile_entry_id/upvote', to: 'users#upvote'
    post '/users/:id/tile_entries/:tile_entry_id/remove_upvote', to: 'users#remove_upvote'
    post '/users/:id/tile_entries/:tile_entry_id/downvote', to: 'users#downvote'
    post '/users/:id/tile_entries/:tile_entry_id/remove_downvote', to: 'users#remove_downvote'

    # user favorite categories
    get '/users/:id/fav_categories', to: 'users#fav_categories'
    post '/users/:id/categories/:category_id/add_to_fav', to: 'users#add_to_fav_categories'
    post '/users/:id/categories/:category_id/remove_from_fav', to: 'users#remove_from_fav_categories'

    # tile_entries
    get '/all_tiles_from_book/:id', to: 'books#tiles'
    get '/tile_entries/guest_feed', to: 'tile_entries#guest_feed'
    get '/users/:id/user_feed', to: 'tile_entries#user_feed'
    get '/users/:id/categories_feed', to: 'tile_entries#categories_feed'
    get '/users/:id/following_feed', to: 'tile_entries#following_feed'

    get '/users/:username', to: 'users#show', constraints: { username: /[0-z.]+/ }

    resources :authors, only: %i[show create]
    resources :categories, only: :index
    get '/categories/:slug/books', to: 'categories#books'
    get '/books/:id/recommendations', to: 'books#recommendations'

    resources :books
    get '/books/:id/tile_entries', to: 'books#tile_entries'

    # elasticsearch actions
    post '/search/books', to: 'search_requests#search_books'
    post '/search/authors', to: 'search_requests#search_authors'

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
