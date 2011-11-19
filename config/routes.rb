OpenfileNames::Application.routes.draw do
  match '/names/:last_name', :to => 'names#show'

  root :to => 'names#index'
end
