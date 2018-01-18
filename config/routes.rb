Rails.application.routes.draw do

  resources :users, except: [:destroy, :show]
  
  devise_for :users, controllers: {
      sessions: 'users/sessions',
      passwords: 'users/passwords',
      confirmations: 'users/confirmations'
  }
  
  devise_scope :user do
    root to: "users/sessions#new"
    post "/update_user_profile" => "users/sessions#update_user_profile"
    post '/add_address' => "users/sessions#add_address"
    get "/edit_password" => 'users/passwords#edit'
    get "/update_password" => 'users/passwords#update'
    put "/update_password" => 'users/passwords#update'
    post "/update_password" => 'users/passwords#update'
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  post '/create_location' => "home#create_location"
  get "/add_new_location" => "home#add_new_location", as: "add_new_location" 
  get "/edit_location/:id" => "home#edit_location", as: "edit_location"
  put "home/:id/update_location" => "home#update_location"
  patch "home/:id/update_location" => "home#update_location", as: "update_location"
  post '/current_location/:id' => "clients#current_location"                                    
  post 'home/index'
  get 'home/index'  
  get 'home/request_pending' 
  get 'home/total_reviews'
  get "/chart_data" => "home#chart_data", as: "chart_data" 
  get "/notification_settings" => "home#notification_settings", as: "notification_settings" 
  post "/update_notification_settings" => "home#update_notification_settings", as: "update_notification_settings"
  get 'home/settings_user'
  get 'home/settings_client'
  get 'home/admin_profile'
  # get 'home/notification_settings'
  get 'home/add_address'
  get 'home/location_listing'
  get 'home/reviews'
  post 'home/reviews_location'
  post 'home/filter_reviews'
  get 'home/requests'
  get 'home/review_history'
  get "/request_add_location" => "home#request_add_location"
  post "/send_request_add_location" => "home#send_request_add_location"
  post "/contact_sale" => "home#contact_sale"
  get "/contact_sales" => "home#contact_sales"
  get 'cities/:states', to: 'application#cities'
  get 'states/:country', to: 'application#states'
  get 'cities/:country/:state', to: 'application#cities'
  get  'clients/send_request'
  post 'clients/send_request'
  post '/user_google_review/:id' => "clients#user_google_review"
  get  'clients/user_google_review/:id' => "clients#user_google_review", as: "user_google_review"
  get  'clients/request_review'
  post '/review_feedback/:id' => "clients#review_feedback"
  get  '/review_feedback/:id' => "clients#review_feedback", as: "review_feedback"
  post '/user_feedback/:id' => 'clients#user_feedback', as: 'user_feedback'
  post '/google_request/:id' => 'clients#google_request', as: 'google_request'
  get  'clients/template'
  post 'clients/create_template'
  get 'clients/create_template'
  get 'home/settings_subscription'
  post 'home/subscriptions'
  get 'home/get_billing_client_date'
  post 'clients/bulk_send_request'
  get 'clients/bulk_send_request'
  get 'clients/add_gmb_account_details_for_client'
  post "/update_gmb_account_details_for_client" => "clients#update_gmb_account_details_for_client", as: 'update_gmb_account_details_for_client'
  post 'clients/bulk_send_request_data'
  get 'clients/privacy_policy'
  get '/feedback_response/:id' => "clients#feedback_response", as: "feedback_response"
  get 'clients/created_password/:id' => "clients#created_password", as: "created_password" 
  post 'clients/created_passwords' 
  get 'application/client_location'
  post 'application/client_location'
  get '/responses/user_response'
  get 'application/client_users'
  post 'application/client_users'
  get '/home/add_note_for_reviews'
  get '/home/add_note_for_google_reviews'
  post '/home/add_note_for_google_reviews'
  post 'clients/csv_heading'
  get "/new_super_user" => "users#new_super_user", as: "new_super_user" 
  post "/create_super_user" => "users#create_super_user"
  get ":id/edit_super_user" => "users#edit_super_user", as: "edit_super_user"
  put "users/:id/update_super_user" => "users#update_super_user"
  patch "users/:id/update_super_user" => "users#update_super_user", as: "update_super_user"
  post 'clients/auto_generate'
  get 'clients/add_templateby_email'
  get 'clients/add_templateby_sms'
  get 'change_country_code/:country_code', to: 'application#change_country_code'
  get 'clients/edit'
  post 'update_client/:id' => "clients#update_client", as: "update_client"
  get 'clients/edit_sms'
  post 'update_client_sms/:id' => "clients#update_client_sms", as: "update_client_sms"
  get '/responses/google_review_reply'
end
