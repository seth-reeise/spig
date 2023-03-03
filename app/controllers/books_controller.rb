class BooksController < ApplicationController
  require 'uri'
  require 'net/http'

  def index
    uri = URI('https://sfof9o2xn8.execute-api.us-east-1.amazonaws.com/books')
    res = Net::HTTP.get_response(uri)
    books_data = JSON.parse(res.body, symbolize_names: true)[:body] if res.is_a?(Net::HTTPSuccess)

    books_data.each do |book_data|
      isbn = book_data[:isbn].nil? ? "Not Found" : book_data[:isbn]
      year = book_data[:isbn].nil? ? "X" : book_data[:year]
      book = Book.find_or_create_by(isbn: isbn)
      book.update(title: book_data[:title], author: book_data[:author], year: year)
    end

    @books = Book.all

    if params[:title].present?
      @books = @books.where('title LIKE ?', "%#{params[:title]}%")
    end

    @books = @books.paginate(page: params[:page], per_page: 10)
  end
end

