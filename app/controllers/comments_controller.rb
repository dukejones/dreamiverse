class CommentsController < ApplicationController
  def create
    @entry = Entry.find params[:entry_id]
    raise "Empty comment!" if params[:comment][:body].blank?
    @comment = Comment.create!(params[:comment].merge(entry_id: params[:entry_id]))
    respond_to do |format|
      format.html { redirect_to(user_entry_path(@entry.user.username, @entry) + '#bottom') }
      format.json { render :json => { :comment => @comment } }
    end
    
    @entry.add_starlight!(5) if @comment.starlight_worthy?
  rescue
    redirect_to user_entry_path(@entry.user.username, @entry), :alert => 'You must enter a comment.'
  end
  
  def destroy
    comment = Comment.where(id: params[:id], entry_id: params[:entry_id]).first

    if comment
      comment.destroy
    
      render :json => { type: 'ok', message: "Comment #{comment.id} destroyed."}
    else
      # Mail error here
      render :json => { type: 'error', message: "Delete failed: could not find comment #{params[:id]}."}
    end
  end
end
