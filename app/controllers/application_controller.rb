class ApplicationController < ActionController::Base
  helper_method :current_user
  protect_from_forgery
  def current_user
    User.first
  end
end
