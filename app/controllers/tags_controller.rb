class TagsController < ApplicationController
  def create
    @entry = Entry.find params[:entry_id]

    what = What.for(params[:what_name])
    
    @entry.add_what_tag(what)
    @entry.reorder_tags
    
    tag_html = render_to_string(partial: 'entries/tag', locals: {what: what, close_button: true })

    render :json => { type: 'ok', what_id: what.id, html: tag_html }
  rescue => e
    render :json => { type: 'error', message: e.message }
  end

    
  def destroy
    # noun_type is currently always 'what'
    what = What.find(params[:what_id])
    tag = Tag.where(entry_id: params[:entry_id], noun_id: params[:what_id], noun_type: 'What').first

    tag.destroy
    
    entry = Entry.find(params[:entry_id])
    entry.reorder_tags
    
    render :json => { type: 'ok', message: "destroyed" }
  rescue => e
    render :json => { type: 'error', message: e.message }
  end
  
  def order_custom_tags
    Tag.order_custom_tags(params[:entry_id],params[:position_list])
    render :json => {:type => 'ok'}
  end  
end
