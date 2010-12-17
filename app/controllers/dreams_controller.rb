class DreamsController < ApplicationController
  def index
    render :text => "All yo dreams!!\n#{current_user.to_yaml}"
  end
end
