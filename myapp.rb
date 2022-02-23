# frozen_string_literal: true

require 'sinatra'
require 'csv'

before do
  @file_name = 'data.csv'
  @id_file_name = 'id.txt'
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
  id = fetch_current_id
  title = params[:title]
  body = params[:body]
  CSV.open(@file_name, 'a') do |f|
    f << [id, title, body]
  end
  increment_id(id)
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
  books = books.each do |book|
    if book[0].to_i == memo_id
      book[1] = new_title
      book[2] = new_body
    end
  end
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
  books.each do |book|
    book[0].to_i == memo_id && books.delete(book)
  end
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
  target_memo = books.find do |book|
    book[0].to_i == memo_id
  end
  @memo[:title] = target_memo[1]
  @memo[:body] = target_memo[2]
end

def fetch_current_id
  if File.exist?(@id_file_name)
    File.open(@id_file_name, 'r') do |f|
      f.gets.to_i
    end
  else
    1
  end
end

def increment_id(id)
  File.open(@id_file_name, 'w') do |f|
    f.puts(id + 1)
  end
end
