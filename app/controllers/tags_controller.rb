class TagsController < ApplicationController
  def create
    @entry = Entry.find params[:entry_id]

    what = What.find_or_create_by_name(params[:what_name])
    # @entry.whats.create!(params[:what_name]) # :created_by => current_user
    Tag.create!(entry: @entry, noun: what)
    
    render :json => { :message => "created", :what_id => what.id }
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
  
  def destroy
    # noun_type is currently always 'what'
    what = What.find(params[:what_id])
    Tag.destroy(entry_id: params[:entry_id], noun: what)
    
    render :json => "destroyed"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
end
