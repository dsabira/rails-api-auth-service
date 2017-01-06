Rails.application.routes.draw do
  use_doorkeeper_openid_connect
  use_doorkeeper do
    skip_controllers :applications, :authorized_applications, :authorizations
  end
  
  devise_for :users, skip: [:registrations, :sessions, :password]
  as :user do
    # only open registration for this basic example
    post 'users', to: 'users/registrations#create', as: :user_registration
  end
end
