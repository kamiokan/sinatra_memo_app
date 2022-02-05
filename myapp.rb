require 'sinatra'
require 'csv'

get '/' do
  redirect '/memo'
end

get '/memo' do
  if File.exist?('data.csv')
    @title_list = ''
    data_list = CSV.read('data.csv')
    data_list.each_with_index do |data, i|
      @title_list += '<li><a href="/memo/'
      @title_list += i.to_s
      @title_list += '/show">'
      @title_list += data[0]
      @title_list += '</a></li>'
    end
  end
  erb :index
end

get '/memo/new' do
  erb :new
end

post '/memo/new' do
  title = params[:title]
  body = params[:body]
  # todo サニタイズする
  CSV.open('data.csv', 'a') do |f|
    f << [title, body]
  end
  redirect '/'
end

get '/memo/:id/show' do
  memo_id = params[:id].to_i
  @title = ''
  @body = ''
  data_list = CSV.read('data.csv')
  data_list.each_with_index do |data, i|
    if i == memo_id
      @memo_id = i
      @title = data[0]
      @body = data[1]
    end
  end
  erb :show
end

get '/memo/:id/edit' do
  memo_id = params[:id].to_i
  @title = ''
  @body = ''
  data_list = CSV.read('data.csv')
  data_list.each_with_index do |data, i|
    if i == memo_id
      @memo_id = i
      @title = data[0]
      @body = data[1]
    end
  end
  erb :edit
end

patch '/memo/:id' do
  memo_id = params[:id].to_i
  new_title = params[:title]
  new_body = params[:body]
  # todo サニタイズする
  data_list = CSV.read('data.csv')
  data_list[memo_id][0] = new_title
  data_list[memo_id][1] = new_body
  File.delete('data.csv')
  data_list.each do |data|
    CSV.open('data.csv', 'a') do |f|
      f << data
    end
  end
  redirect '/'
end

delete '/memo' do
  memo_id = params[:id].to_i
  data_list = CSV.read('data.csv')
  data_list.delete_at(memo_id)
  File.delete('data.csv')
  data_list.each do |data|
    CSV.open('data.csv', 'a') do |f|
      f << data
    end
  end
  redirect '/'
end

# todo 存在しないURLにアクセスした時に、404ページが表示されること
