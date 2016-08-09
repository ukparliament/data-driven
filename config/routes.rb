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
    get '/order_paper_items(.:format)', to: 'order_paper_items#index_by_concept', as: 'order_paper_items'
    get '/petitions(.:format)', to: 'petitions#index_by_concept', as: 'petitions'
  end

  resources :people, only: [:index, :show] do
    get '/oral_questions(.:format)', to: 'oral_questions#index_by_person', as: 'oral_questions'
    get '/written_questions(.:format)', to: 'written_questions#index_by_person', as: 'written_questions'
    get '/votes(.:format)', to: 'votes#index_by_person', as: 'votes'
    get '/committees(.:format)', to: 'committees#index_by_person', as: 'committees'
    get '/written_answers(.:format)', to: 'written_answers#index_by_person', as: 'written_answers'
    get '/order_paper_items(.:format)', to: 'order_paper_items#index_by_person', as: 'order_paper_items'
  end

  resources :written_questions, only: [:index, :show]

  resources :oral_questions, only: [:index, :show]

  resources :committees, only: [:index, :show] do
    get '/edit(.:format)', to: 'committees#edit', as: 'edit'
    post '/edit(.:format)', to: 'committees#update', as: 'update'
  end

  resources :search, only: [:index]

  resources :written_answers, only: [:show]

  resources :houses, only: [:index, :show] do
    get '/oral_questions(.:format)', to: 'oral_questions#index_by_house', as: 'oral_questions'
    get '/written_questions(.:format)', to: 'written_questions#index_by_house', as: 'written_questions'
    get '/divisions(.:format)', to: 'divisions#index_by_house', as: 'divisions'
    get '/people(.:format)', to: 'people#index_by_house', as: 'people'
  end

  resources :divisions, only: [:index, :show] do
    get '/votes(.:format)', to:'votes#index_by_division', as: 'votes'
  end

  resources :constituencies, only: [:index, :show]

  resources :petitions, only: [:index, :show]

  resources :order_papers, only: [:index] do
    get '/order_paper_items(.:format)', to: 'order_paper_items#index_by_order_paper', as: 'business_items'
  end

  resources :order_paper_items, only: [:index, :show] do
    get '/edit(.:format)', to: 'order_paper_items#edit', as: 'edit'
    post '/edit(.:format)', to: 'order_paper_items#update', as: 'update'
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
