require 'bundler'

Bundler.require

# load app and models
dirs = ["models", "sinatra", "managers", "handlers"]
dirs.each do |dir|
    Dir["#{dir}/*.rb"].each {|file| require_relative "../#{file}" }
end

require_relative '../errors.rb'
require_relative '../loanapp.rb'
require 'sinatra/activerecord/rake'