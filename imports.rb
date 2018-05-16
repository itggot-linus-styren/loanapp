require 'bundler'

Bundler.require

#set :environment, :production

require_relative 'config/environments'

# load app and models
dirs = ["models", "controllers", "route_defs", "managers", "handlers"]
dirs.each do |dir|
    Dir["app/#{dir}/*.rb"].each {|file| require_relative file }
end

require_relative 'app/errors.rb'
require_relative 'app/utils.rb'
require_relative 'app/loanapp.rb'