require 'rubygems'
require 'sinatra'

set :sessions, true


get '/inline' do
  "Hello World!!"
end

get '/template' do 
  erb :mytemplate
end

get '/nested_template' do
  erb :"/users/profile"
end

get '/nothere' do
  redirect '/inline'
end

get '/form' do
  erb :form
end

post '/myaction' do
  puts params['username']
end