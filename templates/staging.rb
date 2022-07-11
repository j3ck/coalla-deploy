server '5.9.118.111', :app, :web, :db, primary: true
set :application, 'test.coalla.ru'
set :rails_env, :staging
set :branch, 'development'