Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'application#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  resources :concepts, only: [:index, :show] do
    get '/oral_questions(.:format)', to: 'oral_questions#index_by_concept', as: 'oral_questions'
    get '/written_questions(.:format)', to: 'written_questions#index_by_concept', as: 'written_questions'
    get '/divisions(.:format)', to: 'divisions#index_by_concept', as: 'divisions'
  end

  resources :people, only: [:index, :show] do
    get '/oral_questions(.:format)', to: 'oral_questions#index_by_person', as: 'oral_questions'
    get '/written_questions(.:format)', to: 'written_questions#index_by_person', as: 'written_questions'
    get '/votes(.:format)', to: 'votes#index_by_person', as: 'votes'

  end

  resources :written_questions, only: [:index, :show]

  resources :oral_questions, only: [:index, :show]

  resources :committees, only: [:index, :show]

  resources :search, only: [:index]

  resources :written_answers, only: [:show]

  resources :houses, only: [:index, :show] do
    get '/oral_questions(.:format)', to: 'oral_questions#index_by_house', as: 'oral_questions'
    get '/written_questions(.:format)', to: 'written_questions#index_by_house', as: 'written_questions'
    get '/divisions(.:format)', to: 'divisions#index_by_house', as: 'divisions'
  end

  resources :divisions, only: [:index, :show] do
    get '/votes(.:format)', to:'votes#index_by_division', as: 'votes'
  end


  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
