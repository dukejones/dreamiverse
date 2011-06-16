class BooksController < ApplicationController
  
  def index
    if params[:user_id]
      @books = Book.where(user_id: @params.user_id)
    else
      @books = Book.where(user_id: current_user.id)
    end
    @book = @books.where(enabled: true)
    respond_to do |format|
      format.html { render(partial: 'books/books') }
      format.json { render :json => { :book => book } }
    end
  end
  
  def create
    book = Book.create!(params[:book].merge({
      user_id: current_user.id,
      enabled: true
    }))
    respond_to do |format|
      format.html { render :text => "new book has been created" }
      format.json { render :json => { :book => book } }
    end
  end
  
  def update
    book = Book.find(params[:id])
    respond_to do |format|
      if book.update_attributes(params[:book])
        format.html { render :text => 'book has been updated' }
        format.json  { render json: {type: 'ok', message: 'book has been updated'} }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => { type: 'error', errors: book.errors, status: :unprocessable_entity } }
      end
    end
  end
  
  def show
    @entries = Entry.where(book_id: params[:id]) if params[:id]
    respond_to do |format|
      format.html { render(partial:"books/show") }
    end
  end
  
  def new
    respond_to do |format|
      format.html { render(partial:"books/book") }
    end
  end
  
  def edit
  end
  
  def destroy
    book = Book.find params[:id]
    respond_to do |format|
      if book.update_attributes({enabled: false})
        format.html { render :text => 'book has been disabled' }
        format.json  { render json: {type: 'ok', message: 'book has been disabled'} }
      else
        format.html { render :action => 'delete' }
        format.json  { render :json => { type: 'error', errors: book.errors, status: :unprocessable_entity } }
      end
    end
  end

end
