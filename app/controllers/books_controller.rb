class BooksController < ApplicationController
  
  def index
  end
  
  def create
    book = Book.create!(params[:book])
    redirect_to new_dictionary_word_path(@dict)
  end
  
  def update
    Book.find(params[:id]).update_attributes(params[:book])
  end
  
  def show
  end
  
  def new
  end
  
  def edit
  end
  
  def destroy
    @book = Book.find params[:id]
    @book.destroy
  end

end
