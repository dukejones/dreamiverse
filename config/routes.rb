
Dreamcatcher::Application.routes.draw do
  # Authorization Routes
  namespace "user" do
    resource :session
    resource :registration
  end
  post  'login'  => 'user/sessions#create', :as => :login
  get   'login'  => 'user/sessions#new', :as => :login
  match 'logout' => 'user/sessions#destroy', :as => :logout
  match 'join'   => 'user/registrations#new', :as => :join
  get   'forgot' => 'user/registrations#forgot_password', :as => :forgot_password
  post  'forgot' => 'user/registrations#send_password_reset'
  get   'reset-password/:username/:reset_code', :to => 'user/registrations#reset_password', :as => :reset_password
  post  'reset-password', :to => 'user/registrations#do_password_reset', :as => :do_password_reset
  match 'auth/:provider/callback', :to => 'user/authentications#create'
  delete 'auth/:id', :to => 'user/authentications#destroy', constraints: {id: /\d+/}

  # Universal 
  match '/dreamstars' => 'users#index', :as => :dreamstars
  match '/stream' => 'entries#stream', :as => :stream
  get  '/feedback' => 'home#feedback', :as => :feedback
  post '/feedback' => 'home#submit_feedback'
  match '/random' => 'entries#random', :as => :random
  match '/terms' => 'home#terms', :as => :terms

  # Resources

  resource :user do
    post 'follow'
    post 'bedsheet'
    post 'avatar'
    post 'location', :to => 'users#create_location'
    get  'confirm/:id/:confirmation', as: 'confirm', to: 'users#confirm', constraints: {id: /\d+/}
    get  'not-my-email/:id/:confirmation', as: 'wrong', to: 'users#wrong_email', constraints: {id: /\d+/}
  end

  # Random path from dreams.js
  match 'parse/title', to: 'home#parse_url_title'


  # Images
  match 'images/uploads/:id-:descriptor(-:size).:format', to: 'images#resize', 
    constraints: {id: /\d+/, descriptor: /[^-]*/, size: /\d+/ }
  resources :images do
    collection do
      get 'manage'
      get 'artists'
      get 'albums'
    end
    member do
      post 'disable'
    end
  end
  match 'artists', to: 'images#artists'
  match 'albums', to: 'images#albums'

  # Dream Dictionaries
  resources :dictionaries do
    resources :words
  end
  

  # Tagging
  resources :tags do
    collection do
      post '/', :to => 'tags#create'
      put :order_custom, :to => 'tags#order_custom_tags'
      delete '/(:noun_type)', :to => 'tags#destroy', :constraints => {noun_type: /who|what|where/}
    end
  end
  
  resources :entries do
    collection do
      get 'random' 
    end
    member do
      post 'bedsheet', :to => 'entries#bedsheet'
    end
    resources :comments
  end

  # Username-Specific Routes
  # username_constraint = UsernameConstraint.new
  scope ':username' do
       
    # Entries
    match "/dreams", :to => 'entries#index', 'entry_type' => 'dream', :as => 'dreams'
    match "/visions", :to => 'entries#index', 'entry_type' => 'vision', :as => 'visions'
    match "/experiences", :to => 'entries#index', 'entry_type' => 'experience', :as => 'experiences'
    match "/articles", :to => 'entries#index', 'entry_type' => 'article', :as => 'articles'
    
    get '/' => 'entries#index', :as => 'user_entries'
    post '/' => 'entries#create'
    get "/new", :to => 'entries#new', :as => 'new_user_entry'
    get "/:id/edit", :to => 'entries#edit', :constraints => {id: /\d+/}, :as => 'edit_user_entry'
    get "/:id", :to => 'entries#show', :constraints => {id: /\d+/}, :as => 'user_entry'
    put "/:id", :to => 'entries#update', :constraints => {id: /\d+/}
    delete "/:id", :to => 'entries#delete', :constraints => {id: /\d+/}
    
    # resources :entries, :as => 'user_entries'
    # match '/' => redirect("/%{username}/dreams"), :defaults => { :username => ''}

    # Friends & Following
    match 'follow', to: 'users#follow', verb: 'follow', as: 'follow'
    match 'unfollow', to: 'users#follow', verb: 'unfollow', as: 'unfollow'

    ['friends', 'following', 'followers'].each do |mode|
      match mode => 'users#friends', :mode => mode, :as => mode
    end
    
    # route alpha legacy view urls to /username 
    match '/view/:id' => redirect("/%{username}")
    match '/profile' => redirect("/%{username}")
    
  end

  root :to => 'home#index'

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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
