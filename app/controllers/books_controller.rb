class BooksController < ApplicationController
  
  def index
    @books = Book.enabled
    @books = @books.where(user_id: params[:current_user.id])
    respond_to do |format|
      format.html { render(partial: 'books/book') }
      format.json { render :json => { :book => book } }
    end
  end
  
  def create
    book = Book.create!(params[:book])
    respond_to do |format|
      format.html { 'created' }
      format.json { render :json => { :book => book } }
    end
  end
  
  def update
    Book.find(params[:id]).update_attributes(params[:book])
    respond_to do |format|
      format.html { 'updated' }
      format.json { render :json => { :book => book } }
    end
  end
  
  def show
  end
  
  def new
    respond_to do |format|
      format.html { render(partial:"books/book") }
    end
  end
  
  def edit
  end
  
  def destroy
    @book = Book.find params[:id]
    @book.destroy
  end

end
