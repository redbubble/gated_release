GatedRelease::Engine.routes.draw do
  get '/gates' => 'gates#show'
end
