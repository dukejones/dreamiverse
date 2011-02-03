class WordsController < ApplicationController
  before_filter :find_dictionary
  
  def index
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
    @word = Word.find params[:id]
  end
  
  def new
    @word = Word.new
    render 'edit'
  end
  
  def edit
    @word = Word.find params[:id]
  rescue
    redirect_to new_word_path
  end

protected
  def find_dictionary
    @dict = Dictionary.find params[:dictionary_id]
  rescue
    redirect_to new_dictionary_path
  end
end
