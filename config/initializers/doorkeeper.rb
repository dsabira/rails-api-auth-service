# Devise Controller Helpers needed ONLY for sign_in method  
include Devise::Controllers::Helpers

Doorkeeper.configure do
  resource_owner_authenticator do
    current_user || warden.authenticate!(scope: :person)
  end

  resource_owner_from_credentials do |routes|
    u = User.find_for_database_authentication(email: params[:email])
    if u && u.valid_password?(params[:password])
      # sign in added to utilize devise db columns in OpenID connect
      # Note: sign in does not verify password so be sure to include pw check before signing in  
      sign_in(:user, u)
      u
    end
  end

  # Access token expiration time (default 2 hours)
  access_token_expires_in 24.hours

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  # scopes  :api
  # optional_scopes :write
  default_scopes :public
  optional_scopes :openid, :profile, :email

  skip_authorization do |resource_owner, client|
    true
  end

  grant_flows %w(authorization_code implicit password client_credentials)
end
