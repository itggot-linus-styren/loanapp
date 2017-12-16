require 'bundler'

Bundler.require

#set :environment, :production

require_relative 'config/environments'

# load app and models
dirs = ["models", "sinatra", "managers", "handlers"]
dirs.each do |dir|
    Dir["#{dir}/*.rb"].each {|file| require_relative file }
end

require_relative 'errors.rb'
require_relative 'loanapp.rb'
require 'sinatra/activerecord/rake'