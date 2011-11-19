OpenfileNames::Application.routes.draw do
  resources :names, :only => [ :index, :show ]

  root :to => 'names#index'
end
