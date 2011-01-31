class WordsController < ApplicationController
  def index
    @dict = Dictionary.find params[:dictionary_id]
  rescue
    redirect_to new_dictionary_path
  end
  
  def create
    params[:word][:dictionary_id] = params[:dictionary_id]
    word = Word.create!(params[:word])
    redirect_to dictionary_words_path(word.dictionary)
  end
  
  def update
    Word.find(params[:id]).update_attributes(params[:word])
    redirect_to dictionary_words_path(params[:dictionary_id])
  end
  
  def show
    redirect_to dictionary_words_path(params[:dictionary_id])
    @dict = Dictionary.find params[:dictionary_id]
    @word = Word.find params[:id]
  end
  
  def edit
    @dict = Dictionary.find params[:dictionary_id]
    @word = Word.find params[:id]
  end
end
