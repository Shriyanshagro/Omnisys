Rails.application.routes.draw do

    #  to get id along in url use member otherwise collection
  resources :masters do
      member do
          get 'delete'
      end
  end
  resources :stocks do
    #to pass without any id we use collection
    collection  do
      get 'report'
      get 'correct'
      post 'correct'
      get 'batch'
      get 'expiry_date'
      get 'item'
    end
  end
  resources :sales do
      collection do
          get 'customer'
          get 'item'
      end
  end
  resources :purchases do
      collection do
          get 'wholesaler'
          get 'item'
          get 'uom'
      end
  end
  devise_for :users , :sign_out_via => [ :get, :delete ]

  root 'stocks#index'
  get 'reorder/index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
