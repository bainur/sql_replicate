class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate


  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == HTTP_BASIC[:username] && password == HTTP_BASIC[:password]
    end
  end
end
