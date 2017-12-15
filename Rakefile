require 'bundler'

Bundler.require

set :environment, :production

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

# load app and models
dirs = ["models", "sinatra", "managers", "handlers"]
dirs.each do |dir|
    Dir["#{dir}/*.rb"].each {|file| require_relative file }
end

require_relative 'errors.rb'
require_relative 'loanapp.rb'
require 'sinatra/activerecord/rake'