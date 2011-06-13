class CommentsController < ApplicationController
  def index
    @entry = Entry.find params[:entry_id]

    if request.xhr?
      respond_to do |format|
        format.html { render :partial => 'entries/comment_panel', :locals => {:entry => @entry} }
        format.json { render :json => @entry.comments.joins(:user).select('comments.*, users.username, users.image_id') }
      end
    else
      Rails.logger.error("Hit comments#index with a synchronous request.")
      redirect_to entry_path(@entry)
    end
  end
  
  def create
    @entry = Entry.find params[:entry_id]
    raise "Empty comment!" if params[:comment][:body].blank?
    @comment = Comment.create!(params[:comment].merge(entry_id: params[:entry_id]))
    @entry.update_attribute(:new_comment_count, @entry.new_comment_count + 1) unless @entry.user == current_user

    respond_to do |format|
      format.html { redirect_to(user_entry_path(@entry.user.username, @entry) + '#bottom') }
      format.json { render :json => { :comment => @comment } }
    end
    
    @entry.add_starlight!(3) if @entry.user != current_user && @comment.starlight_worthy?
  rescue
    redirect_to user_entry_path(@entry.user.username, @entry), :alert => 'You must enter a comment.'
  end
  
  def destroy
    comment = Comment.where(id: params[:id], entry_id: params[:entry_id]).first
    @entry = Entry.find params[:entry_id]
    @entry.update_attribute(:new_comment_count, @entry.new_comment_count - 1)
    if comment
      comment.destroy
    
      render :json => { type: 'ok', message: "Comment #{comment.id} destroyed."}
    else
      # Mail error here
      render :json => { type: 'error', message: "Delete failed: could not find comment #{params[:id]}."}
    end
  end
end
