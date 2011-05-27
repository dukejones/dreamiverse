
Dreamcatcher::Application.routes.draw do
  constraints(:host => /^www\./) do
    match "(*x)" => redirect { |params, request|
      URI.parse(request.url).tap {|url| url.host.sub!('www.', '') }.to_s
    }
  end

  # Authorization Routes
  namespace "user" do
    resource :session
    resource :registration
  end

  # Authorization and Registration Routes
  post  'login'  => 'user/sessions#create', :as => :login
  get   'login'  => 'user/sessions#new', :as => :login
  match 'logout' => 'user/sessions#destroy', :as => :logout
  match 'join'   => 'user/registrations#new', :as => :join
  get   'forgot' => 'user/registrations#forgot_password', :as => :forgot_password
  post  'forgot' => 'user/registrations#send_password_reset'
  get   'reset-password/:username/:reset_code', :to => 'user/registrations#reset_password', :as => :reset_password
  post  'reset-password', :to => 'user/registrations#do_password_reset', :as => :do_password_reset
  match 'auth/:provider/callback', :to => 'user/authentications#create'
  match 'auth/failure', :to => 'user/authentications#failure'
  delete 'auth/:id', :to => 'user/authentications#destroy', constraints: {id: /\d+/}
  
  # Universal Routes
  get 'today' => 'home#index', :as => :today
  match 'thank_you' => 'home#thank_you', :as => :thank_you
  get  'feedback' => 'home#feedback', :as => :feedback
  post 'feedback' => 'home#submit_feedback'
  match 'terms' => 'home#terms', :as => :terms
  match 'error' => 'home#error'

  match '/dreamstars' => 'users#index', :as => :dreamstars

  match '/admin' => 'admin#admin', :as => :admin
  get '/admin/user_list' => 'admin#user_list', :as => :admin

  
  match '/stream' => 'entries#stream', :as => :stream
  match '/dreamfield' => 'entries#dreamfield', :as => :dreamfield
  match '/random' => 'entries#random', :as => :random


  # Resources

  resource :user do
    post 'follow'
    post 'bedsheet'
    post 'set_view_preferences'
    post 'avatar'
    post 'location', :to => 'users#create_location'
    match 'search', :as => :search
    get  'confirm/:id/:confirmation', as: 'confirm', to: 'users#confirm', constraints: {id: /\d+/}
    get  'not-my-email/:id/:confirmation', as: 'wrong', to: 'users#wrong_email', constraints: {id: /\d+/}
  end

  # Random path from dreams.js
  match 'parse/title', to: 'home#parse_url_title'


  # Images
  match 'images/uploads/:id-:descriptor(-:size).:format', to: 'images#resize', 
    constraints: {id: /\d+/, descriptor: /[^-]*/, size: /\d+/, format: /\w{2,4}/ }
  resources :images do
    collection do
      get 'manager'
      get 'slideshow'
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
      post 'set_view_preferences', :to => 'entries#set_view_preferences'
    end
    resources :comments
  end

  # Username-Specific Routes
  # username_constraint = UsernameConstraint.new
  scope ':username' do
       
    # Entries
    match "/:entry_type", :to => 'entries#index', 
      :constraints => {entry_type: /dreams|visions|experiences|articles|journals/}, :as => 'user_entries_filter'
    
    get '/' => 'entries#index', :as => 'user_entries'
    post '/' => 'entries#create'
    get "/new", :to => 'entries#new', :as => 'new_user_entry'
    get "/:id/edit", :to => 'entries#edit', :constraints => {id: /\d+/}, :as => 'edit_user_entry'
    get "/:id", :to => 'entries#show', :constraints => {id: /\d+/}, :as => 'user_entry'
    put "/:id", :to => 'entries#update', :constraints => {id: /\d+/}
    delete "/:id", :to => 'entries#delete', :constraints => {id: /\d+/}
    
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


  #default landing page
  root :to => 'home#landing_page'

end
