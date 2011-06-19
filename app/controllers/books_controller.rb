class BooksController < ApplicationController
  
  def index
    if params[:user_id]
      @books = Book.where(user_id: @params.user_id)
    else
      @books = Book.where(user_id: current_user.id)
    end
    respond_to do |format|
      format.html { render(partial: 'books/books') }
      format.json { render :json => { :book => book } }
    end
  end
  
  def create
    book = Book.create!(params[:book].merge({user_id: current_user.id}))
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
    @book = Book.find_by_id(params[:id]) if params[:id]
    @user = @book.user
    if request.xhr?
      render(partial: "books/show")
    end
  end
  
  def new
    if request.xhr?
      render(partial:"books/book")
    else
      redirect_to user_entries_path(current_user.username)
    end
  end
  
  def edit
    if request.xhr?
      @book = Entry.find params[:id]
      @book_mode = 'edit'
      render(partial:"books/book")
    else
      redirect_to user_entries_path(current_user.username)
    end
  end
  
  def destroy
    book = Book.find params[:id]
    book.entries.each { |entry| entry.update_attribute(:book_id, nil) }
    respond_to do |format|
      if book.destroy
        format.html { render :text => 'book has been disabled' }
        format.json  { render json: {type: 'ok', message: 'book has been disabled'} }
      else
        format.html { render :action => 'delete' }
        format.json  { render :json => { type: 'error', errors: book.errors, status: :unprocessable_entity } }
      end
    end
  end

end
