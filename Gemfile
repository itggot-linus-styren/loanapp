source 'https://rubygems.org'

ruby '2.4.1p111'

gem 'slim'
gem 'sinatra'
gem 'sinatra-flash'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'sinatra-contrib', require: false
gem 'bcrypt'
gem 'rake'

group :development, :test do
    gem('rerun', github: 'alexch/rerun')
    gem 'sqlite3'
    gem 'rails-erd', require: false
end
group :production do
    gem 'pg'
end