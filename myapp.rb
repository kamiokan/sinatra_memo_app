# frozen_string_literal: true

require 'sinatra'
require 'csv'

before do
  @file_name = 'data.csv'
  @memo = { id: '', title: '', body: '' }
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memo'
end

get '/memo' do
  File.exist?(@file_name) && (@books = CSV.read(@file_name))
  erb :index
end

get '/memo/new' do
  erb :new
end

post '/memo/new' do
  title = params[:title]
  body = params[:body]
  CSV.open(@file_name, 'a') do |f|
    f << [title, body]
  end
  redirect '/'
end

get '/memo/:id/show' do
  @memo[:id] = params[:id].to_i
  find_memo_by_id(@memo[:id])
  erb :show
end

get '/memo/:id/edit' do
  @memo[:id] = params[:id].to_i
  find_memo_by_id(@memo[:id])
  erb :edit
end

patch '/memo/:id' do
  memo_id = params[:id].to_i
  new_title = params[:title]
  new_body = params[:body]
  books = CSV.read(@file_name)
  books[memo_id][0] = new_title
  books[memo_id][1] = new_body
  File.delete(@file_name)
  books.each do |data|
    CSV.open(@file_name, 'a') do |f|
      f << data
    end
  end
  redirect '/'
end

delete '/memo' do
  memo_id = params[:id].to_i
  books = CSV.read(@file_name)
  books.delete_at(memo_id)
  File.delete(@file_name)
  books.each do |data|
    CSV.open(@file_name, 'a') do |f|
      f << data
    end
  end
  redirect '/'
end

not_found do
  '404 not found'
end

def find_memo_by_id(memo_id)
  books = CSV.read(@file_name)
  books.each_with_index do |book, i|
    next if i != memo_id

    @memo[:title] = book[0]
    @memo[:body] = book[1]
  end
end
