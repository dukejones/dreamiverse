class DictionariesController < ApplicationController
  def index
    @dicts = Dictionary.all
  end

  def new
    @dict = Dictionary.new
  end

  def create
    dict = Dictionary.create!(params[:dictionary])
    redirect_to dictionary_words_path(dict)
  end
  
  def show
    @dict = Dictionary.find params[:id]
  end
end
