Rails.application.routes.draw do
  scope path: '/api' do
    post '/login', to: 'authentication#authenticate'
    get '/logout', to: 'authenticate#logout'
    get '/logged_in', to: 'authentication#logged_in'
    post '/signup', to: 'users#create'

    post '/follow', to: 'users#add_following'
    post '/unfollow', to: 'users#remove_following'

    get '/all_book_tiles', to: 'book_tiles#tiles_index'
    get '/top_tiles', to: 'tile_entries#top_tiles'
    get '/all_tiles_from_book/:id', to: 'books#tiles'

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

    resources :categories, only: :index
  end
end
