class TagsController < ApplicationController
  def create
    @entry = Entry.find params[:entry_id]

    what = What.find_or_create_by_name(params[:what_name])
    
    @entry.add_what_tag(what)
    @entry.reorder_tags
    
    # t = Tag.new
    # next_pos = t.get_next_custom_position(params[:entry_id])
    # Tag.create!(entry: @entry, noun: what, position: next_pos, kind: 'custom')
    # @entry.whats.create!(params[:what_name]) # :created_by => current_user
    
    render :json => { :message => "created", :what_id => what.id }
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end

    
  def destroy
    # noun_type is currently always 'what'
    what = What.find(params[:what_id])
    tag = Tag.where(entry_id: params[:entry_id], noun_id: params[:what_id], noun_type: 'What').first

    tag.destroy
    
    render :json => "destroyed"
  rescue => e
    render :json => e.message, :status => :unprocessable_entity
  end
  
  def sort_custom_tags
    Tag.sort_custom_tags(params[:entry_id],params[:position_list])
    render :json => {:type => 'ok'}
  end  
end
