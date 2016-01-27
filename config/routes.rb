
Rails.application.routes.draw do
  constraints(:host => /^www\./) do
    get "(*x)" => redirect { |params, request|
      URI.parse(request.url).tap {|url| url.host.sub!('www.', '') }.to_s
    }
  end


  # Authorization Routes
  namespace "user" do
    resource :session
    resource :registration
  end

  # Authorization and Registration Routes
  post  'login'  => 'user/sessions#create', :as => :login_post
  get   'login'  => 'user/sessions#new', :as => :login
  get   'logout' => 'user/sessions#destroy', :as => :logout
  get   'join'   => 'user/registrations#new', :as => :join
  get   'forgot' => 'user/registrations#forgot_password', :as => :forgot_password
  post  'forgot' => 'user/registrations#send_password_reset'
  get   'reset-password/:username/:reset_code', :to => 'user/registrations#reset_password', :as => :reset_password
  post  'reset-password', :to => 'user/registrations#do_password_reset', :as => :do_password_reset
  get   'auth/:provider/callback', :to => 'user/authentications#create'
  get   'auth/failure', :to => 'user/authentications#failure'
  delete 'auth/:id', :to => 'user/authentications#destroy', constraints: {id: /\d+/}

  get 'farewell', to: 'home#farewell', :as => :farewell
  get 'thank_you', to: 'home#download_all', as: :download_all
  post 'collect_email', to: 'home#collect_email', as: :collect_email

  # THESE TWO LINES WILL SHUT DOWN DREAMCATCHER
  # root to: 'home#farewell'
  # get '*all', to: redirect('/farewell')
  root :to => 'home#landing_page'

  # Universal Routes
  get 'today' => 'home#index', :as => :today
  get 'thank_you' => 'home#thank_you', :as => :thank_you
  get  'feedback' => 'home#feedback', :as => :feedback
  post 'feedback' => 'home#submit_feedback'
  get  'terms' => 'home#terms', :as => :terms
  get  'error' => 'home#error'

  get '/dreamstars' => 'users#index', :as => :dreamstars

  get '/admin' => 'admin#admin'
  get '/admin/users' => 'admin#user_list'
  get '/admin/line_chart' => 'admin#load_line_chart'
  get '/admin/pie_chart' => 'admin#load_pie_chart'
  get '/admin/bedsheets' => 'admin#load_bedsheets'

  get '/stream' => 'entries#stream', :as => :stream
  get '/dreamfield' => 'entries#dreamfield', :as => :dreamfield
  get '/random' => 'entries#random', :as => :random

  # Mounts
  mount Resque::Server, :at => '/resque'

  get "/facebook_channel", :to => proc {|env| [200, {}, ['<script src="//connect.facebook.net/en_US/all.js"></script>']] }, :as => :facebook_channel

  # Resources

  resource :user do
    get  'context_panel'
    post 'follow'
    post 'bedsheet'
    post 'set_view_preferences'
    post 'avatar'
    post 'location', :to => 'users#create_location'
    get  'search', :as => :search
    get  'confirm/:id/:confirmation', as: 'confirm', to: 'users#confirm', constraints: {id: /\d+/}
    get  'not-my-email/:id/:confirmation', as: 'wrong', to: 'users#wrong_email', constraints: {id: /\d+/}
  end

  # Random path from dreams.js
  get 'parse/title', to: 'home#parse_url_title'


  # Images
  # get 'images/uploads/:id-:descriptor(-:size).:format', to: 'images#resize',
  #   constraints: {id: /\d+/, descriptor: /[^-]*/, size: /\d+/, format: /\w{2,4}/ }

  get "#{Image::CACHE_DIR}/:year/:month/:filename-:descriptor(-:size).:format", to: 'images#resize',
    constraints: {year: /\d{4}/, month: /\d{1,2}/, descriptor: /[^\d]+/, size: /\d+/, format: /\w{2,4}/ }

  resources :images do
    collection do
      get 'manager'
      get 'slideshow'
      get 'artists'
      get 'albums'
      post 'updatefield'
    end
    member do
      post 'disable'
    end
  end
  get 'artists', to: 'images#artists'
  get 'albums', to: 'images#albums'

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
      get  'next', :to => 'entries#next', :as => 'next'
      get  'previous', :to => 'entries#previous', :as => 'previous'
      get 'download', :to => 'entries#download', :as => 'download'
    end
    resources :comments
  end

  resources :books

  # Username-Specific Routes
  # username_constraint = UsernameConstraint.new
  scope ':username' do

    # Entries
    get "/:entry_type", :to => 'entries#index',
      :constraints => {entry_type: /dreams|visions|experiences|articles|journals/}, :as => 'user_entries_filter'

    get '/' => 'entries#index', :as => 'user_entries'
    post '/' => 'entries#create'
    get "/new", :to => 'entries#new', :as => 'new_user_entry'
    get "/:id/edit", :to => 'entries#edit', :constraints => {id: /\d+/}, :as => 'edit_user_entry'
    get "/:id", :to => 'entries#show', :constraints => {id: /\d+/}, :as => 'user_entry'
    get "/:id/pdf", to: 'entries#pdf_view', :constraints => {id: /\d+/}, :as => 'user_entry_pdf'
    put "/:id", :to => 'entries#update', :constraints => {id: /\d+/}
    delete "/:id", :to => 'entries#delete', :constraints => {id: /\d+/}

    get 'all', to: 'entries#all', as: 'all_entries'

    # Friends & Following
    get 'follow', to: 'users#follow', verb: 'follow', as: 'follow'
    get 'unfollow', to: 'users#follow', verb: 'unfollow', as: 'unfollow'

    ['friends', 'following', 'followers'].each do |mode|
      get mode => 'users#friends', :mode => mode, :as => mode
    end

    # route alpha legacy view urls to /username
    get '/view/:id' => redirect("/%{username}")
    get '/profile' => redirect("/%{username}")

  end



end
