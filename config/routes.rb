class UsernameConstraint
  def initialize
    @usernames = User.select('username').all.map(&:username)
  end
  
  def matches?(request)
    request.url
  end
end

Dreamcatcher::Application.routes.draw do
  # Authorization Routes
  namespace "user" do
    resource :session
    resource :registration
  end
  post 'login' => 'user/sessions#create', :as => :login
  get  'login' => 'user/sessions#new', :as => :login
  match 'logout' => 'user/sessions#destroy', :as => :logout

  match 'auth/:provider/callback', :to => 'user/authentications#create'

  # Universal
  match 'dreamstars' => 'users#index', :as => :dreamstars
  match 'stream' => 'entries#stream', :as => :stream

  # Resources

  resource :user do
    post 'follow'
    post 'bedsheet'
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
  # match '#:tag', :to => 'tags#show'
  resources :tags

  resources :entries do
    collection do
      post 'bedsheet'
    end
  end
  # Username-Specific Routes
  # username_constraint = UsernameConstraint.new
  scope ':username' do
    # Entries
    match 'follow', to: 'users#follow', verb: 'follow', as: 'follow'
    match 'unfollow', to: 'users#follow', verb: 'unfollow', as: 'unfollow'
    resources :entries, :as => 'user_entries'
    match '/' => 'entries#index'
    # match '/' => redirect("/%{username}/dreams"), :defaults => { :username => ''}

    # Friends
    ['friends', 'following', 'followers'].each do |mode|
      match mode => 'users#friends', :mode => mode, :as => mode
    end
  end
  # match ':username', :to => 'dreams#index' #, :constraint => username_constraint


  #root :to => 'dreams#stream'#, :as => :stream
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
