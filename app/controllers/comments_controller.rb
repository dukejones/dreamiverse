class CommentsController < ApplicationController
  def create
    raise "Empty comment!" if params[:comment][:body].blank?
    @entry = Entry.find params[:entry_id]
    created_comment = Comment.create!(params[:comment].merge(entry_id: params[:entry_id]))
    respond_to do |format|
      format.html { render :partial => 'entries/comment', :object => created_comment }
      format.json { render :json => { :comment => created_comment } }
    end
  end
  
  def destroy
    comment = Comment.where(id: params[:id], entry_id: params[:entry_id]).first
    comment.destroy
    
    render :json => { type: 'ok', message: "Comment #{comment.id} destroyed."}
  end
end
