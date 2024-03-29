Rails.application.routes.draw do
  # auth
  post '/login', to: 'authentication#authenticate'
  get '/logout', to: 'authentication#logout'
  get '/logged_in', to: 'authentication#logged_in'
  post '/signup', to: 'users#create'
  post '/confirm', to: 'users#confirm_account'

  resources :users, only: :nil do
    resource :avatar, except: %i[index update]

    resources :book_tiles do
      get :nonpaginated, on: :collection
      get :temporary, on: :collection
      delete :destroy_temporary, on: :member
    end

    resources :conversations, only: %i[index show create]
    resources :tile_entries, only: :index do
      collection do
        get :commented_entries
      end
    end

    resources :following, only: %i[index create destroy] do
      get :nonpaginated, on: :collection
    end

    resources :followers, only: :index do
      get :nonpaginated, on: :collection
    end

    resources :fav_books, only: %i[index create destroy] do
      get :nonpaginated, on: :collection
    end

    resources :fav_tile_entries, only: %i[index create destroy] do
      get :nonpaginated, on: :collection
    end

    resources :fav_categories, only: %i[index create destroy]

    resources :upvoted_entries, only: %i[index create destroy]
    resources :downvoted_entries, only: %i[index create destroy]

    member do
      resources :feed, only: :nil do
        collection do
          get :user_feed
          get :categories_feed
          get :following_feed
        end
      end
    end

    resources :books, only: :nil do
      get :book_index, on: :member, to: 'tile_entries#book_index'
      resources :book_tiles, only: :nil do
        get :available, on: :collection
      end
    end
  end

  # user route by username
  get '/users/:username', to: 'users#show', constraints: { username: /[0-z.]+/ }

  # guest user feed
  get '/feed/guest_feed', to: 'feed#guest_feed'

  resources :conversations, only: :nil do
    resources :messages, only: %i[index create]
  end

  resources :book_tiles, only: :nil do
    resources :tile_entries
    resources :temporary_entries
  end

  resources :books do
    get :tile_entries, on: :member
    get :recommendations, on: :member
  end

  resources :authors, only: %i[show create]

  resources :categories, only: %i[index show], param: :slug

  resources :tile_entries, only: %i[show] do
    resources :comments
  end

  # resources :comments, only: :nil do
  #   resources :comments
  # end

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

  # stats routes
  get '/users/:id/stats', to: 'stats#user_stats'
  get '/stats/trending', to: 'stats#trending'

  # elastic search actions
  post '/elastic_search/books', to: 'elastic_search#search_books'

  # weekly trend
  get '/weekly_trend', to: 'week_trend#index'
end
