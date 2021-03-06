GatedRelease::Engine.routes.draw do
  resources :gates, only: [:index], path: '/' do
      member do
        post :open
        post :close
        post :limit
        post :allow_more
        post :percentage
      end
    end
end
