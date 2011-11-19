OpenfileNames::Application.routes.draw do
  resources :names

  root :to => 'names#index'
end
