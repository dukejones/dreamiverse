class CommentsController < ApplicationController
  def create
    debugger

    Comment.create!(params[:comment].merge(entry_id: params[:entry_id]))
    redirect_to entry_path(params[:entry_id])
  end
end
