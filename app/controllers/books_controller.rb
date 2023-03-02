class BooksController < ApplicationController
  require 'uri'
  require 'net/http'

  def index
    uri = URI('https://sfof9o2xn8.execute-api.us-east-1.amazonaws.com/books')
    res = Net::HTTP.get_response(uri)
    books_data = JSON.parse(res.body, symbolize_names: true)[:body] if res.is_a?(Net::HTTPSuccess)

    books_data.each do |book_data|
      book = Book.find_or_create_by(isbn: book_data[:isbn])
      book.update(title: book_data[:title], author: book_data[:author], publication_date: book_data[:year])
    end

    @books = Book.all

    if params[:title].present?
      @books = @books.where('title LIKE ?', "%#{params[:title]}%")
    end

    @books = @books.paginate(page: params[:page], per_page: 10)
  end
end

