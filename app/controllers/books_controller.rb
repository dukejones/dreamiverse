class BooksController < ApplicationController
  
  def index
    @books = Book.where(user_id: current_user.id)
    respond_to do |format|
      format.html { render(partial: 'books/books') }
      format.json { render :json => { :book => book } }
    end
  end
  
  def create
    book = Book.create!(params[:book].merge({
      user_id: current_user.id
    }))
    respond_to do |format|
      format.html { 'created' }
      format.json { render :json => { :book => book } }
    end
  end
  
  def update
    book = Book.find(params[:id])
    respond_to do |format|
      if book.update_attributes(params[:book])
        format.html { render :text => 'Book was successfully updated.' }
        format.json  { render json: {type: 'ok', message: 'Book was successfully updated.'} }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => { type: 'error', errors: book.errors, status: :unprocessable_entity } }
      end
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
