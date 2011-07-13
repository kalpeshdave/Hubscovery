Instanthub::Application.routes.draw do
  resources :searches
  match "/perma/:link", :to => "searches#show", :as => :permalink
  match "/search", :to => "searches#new"
  root :to => "searches#new"
end
