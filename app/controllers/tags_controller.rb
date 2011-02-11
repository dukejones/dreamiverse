class TagsController < ApplicationController
  def create
    @entry = Entry.find params[:entry_id]
    @entry.whats.create!(params[:tag_name]) # :created_by => current_user
    render :json => "created"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
  
  def destroy
    
  end

end
