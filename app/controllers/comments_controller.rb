class CommentsController < ApplicationController
  def create
    created_comment = Comment.create!(params[:comment].merge(entry_id: params[:entry_id]))
    
    respond_to do |format|
      format.html { redirect_to entry_path(params[:entry_id]) }
      format.json { render :json => { :comment => created_comment } }
    end
  end
end
