Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace 'api' do
    namespace 'v1' do
      load File.expand_path('../../app/controllers/api/v1/login_controller.rb', __FILE__)
      resources :unit_details
      resources :booking_details
      post '/signup' => 'login#signup'
      post '/login' => 'login#userLogin'
      delete '/user' => 'login#removeUser'
      put '/user' => 'login#updateUser'
      get '/user' => 'login#getUsers'
      get '/agents' => 'login#getAgents'
      post '/multiInsert' => 'unit_details#multiInsert'
      get '/image' => 'booking_details#image'
      get '/bookings' => 'booking_details#bookings'
    end
  end
end
