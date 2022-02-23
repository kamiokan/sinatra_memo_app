# frozen_string_literal: true

require 'sinatra'
require 'csv'
require 'pg'

before do
  @memo = { id: '', title: '', body: '' }
  db_config = { host: 'localhost', user: 'kamiokan', password: '', dbname: 'postgres', port: 5432 }
  @conn = ConnectDB.new(db_config)
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
  @memos = @conn.select_memos
  erb :index
end

get '/memo/new' do
  erb :new
end

post '/memo/new' do
  @memo[:title] = params[:title]
  @memo[:body] = params[:body]
  @conn.add_memo(@memo)
  redirect '/'
end

get '/memo/:id/show' do
  memo_id = params[:id].to_i
  @the_memo = @conn.select_memo(memo_id)
  erb :show
end

get '/memo/:id/edit' do
  memo_id = params[:id].to_i
  @the_memo = @conn.select_memo(memo_id)
  erb :edit
end

patch '/memo/:id' do
  @memo[:id] = params[:id].to_i
  @memo[:title] = params[:title]
  @memo[:body] = params[:body]
  @conn.edit_memo(@memo)
  redirect '/'
end

delete '/memo' do
  memo_id = params[:id].to_i
  @conn.delete_memo(memo_id)
  redirect '/'
end

not_found do
  '404 not found'
end

class ConnectDB
  def self.finish
    proc do
      puts 'db connectioin fihished'
      @connection.finish
    end
  end

  def initialize(db_config)
    @connection = PG.connect(db_config)
    @connection.internal_encoding = 'UTF-8'
    ObjectSpace.define_finalizer(self, ConnectDB.finish)
  end

  def select_memos
    @connection.exec('SELECT * FROM memos ORDER BY id')
  end

  def select_memo(id)
    query = 'SELECT * FROM memos WHERE id=$1'
    @connection.prepare('select', query)
    @connection.exec_prepared('select', [id]).first
  end

  def add_memo(memo_info)
    query = 'INSERT INTO memos (title, body) VALUES ($1, $2)'
    @connection.prepare('insert', query)
    @connection.exec_prepared('insert', [memo_info[:title], memo_info[:body]])
  end

  def edit_memo(memo_info)
    query = 'UPDATE memos SET title=$1, body=$2 WHERE id=$3'
    @connection.prepare('update', query)
    @connection.exec_prepared('update', [memo_info[:title], memo_info[:body], memo_info[:id]])
  end

  def delete_memo(id)
    query = 'DELETE FROM memos WHERE id=$1'
    @connection.prepare('delete', query)
    @connection.exec_prepared('delete', [id])
  end
end
