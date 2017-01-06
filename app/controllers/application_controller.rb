class ApplicationController < ActionController::API
  before_action :doorkeeper_authorize!

  include ActionController::MimeResponds
  respond_to :json
end
