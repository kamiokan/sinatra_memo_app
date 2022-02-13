# frozen_string_literal: true

require 'sinatra'
require 'csv'

before do
  @file_name = 'data.csv'
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
  title = h(params[:title])
  body = h(params[:body])
  CSV.open(@file_name, 'a') do |f|
    f << [title, body]
  end
  redirect '/'
end

get '/memo/:id/show' do
  memo_id = params[:id].to_i
  @title = ''
  @body = ''
  books = CSV.read(@file_name)
  books.each_with_index do |data, i|
    next if i != memo_id

    @memo_id = i
    @title = data[0]
    @body = data[1]
  end
  erb :show
end

get '/memo/:id/edit' do
  memo_id = params[:id].to_i
  @title = ''
  @body = ''
  books = CSV.read(@file_name)
  books.each_with_index do |data, i|
    next if i != memo_id

    @memo_id = i
    @title = data[0]
    @body = data[1]
  end
  erb :edit
end

patch '/memo/:id' do
  memo_id = params[:id].to_i
  new_title = h(params[:title])
  new_body = h(params[:body])
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
    CSV.open('data.csv', 'a') do |f|
      f << data
    end
  end
  redirect '/'
end

not_found do
  '404 not found'
end
