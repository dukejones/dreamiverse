class CommentsController < ApplicationController
  def create
    raise "Empty comment!" if params[:comment][:body].blank?
    created_comment = Comment.create!(params[:comment].merge(entry_id: params[:entry_id]))
    respond_to do |format|
      format.html { render :partial => 'entries/comment', :object => created_comment }
      format.json { render :json => { :comment => created_comment } }
    end
  end
end
