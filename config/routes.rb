MusicServer::Application.routes.draw do
  uuid_re = /\w{8}\-(\w{4}\-){3}\w{12}/i
  sha1_re = /\w{40}/i
  # sources
  resources :sources
  match 'sources/:id/scan' => 'sources#scan'

  # images
  get 'images/:checksum', :to => 'images#show', :checksum => sha1_re
  resources :images

  # tracks
  get 'tracks/:uuid', :to => 'tracks#show', :uuid => uuid_re
  get 'tracks/:uuid/artwork', :to => 'tracks#artwork', :uuid => uuid_re
  get 'tracks/:uuid/artwork/pos', :to => 'tracks#artwork', :uuid => uuid_re, :defaults => { :pos => 1 }
  get 'tracks/:id/artwork', :to => 'tracks#artwork', :defaults => { :pos => 1 }
  get 'tracks/:id/artwork/:pos', :to => 'tracks#artwork'
  post 'tracks/deleted', :to => 'tracks#deleted'
  resources :tracks

  # settings
  match 'settings/update' => 'settings#update'
  match 'settings' => 'settings#index'

  # application 
  match 'restart' => 'application#restart'
  match 'info' => 'application#info'
  match 'shutdown' => 'application#shutdown'
  root :to => 'application#index'

  # daemons
  match 'daemons/stop' => 'daemons#stop'
  match 'daemons/start' => 'daemons#start'
  match 'daemons/restart' => 'daemons#restart'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
