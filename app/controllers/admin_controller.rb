class AdminController < ApplicationController
  before_filter :require_user, :require_admin
  
  def admin
    
  end
  
  protected
  
  def require_admin
    unless current_user.auth_level == 5
      flash.alert = "This page requires admin access."
      redirect_to :root and return
    end
  end
end
