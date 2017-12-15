require 'bundler'

Bundler.require

set :environment, :production

# load app and models
dirs = ["models", "sinatra", "managers", "handlers"]
dirs.each do |dir|
    Dir["#{dir}/*.rb"].each {|file| require_relative file }
end

require_relative 'errors.rb'
require_relative 'loanapp.rb'

# add blank, nan and similar method to string class
class String
    def blank?
        self.strip.empty?
    end

    def nan?
        self.to_i.to_s != self
    end

    def similar?(other)
        self.strip.casecmp?(other.strip)
    end
end

module PrettyDate
    def to_pretty
        a = (Time.now-self).to_i
    
        case a
            when 0 then 'just now'
            when 1 then 'a second ago'
            when 2..59 then a.to_s+' seconds ago' 
            when 60..119 then 'a minute ago' #120 = 2 minutes
            when 120..3540 then (a/60).to_i.to_s+' minutes ago'
            when 3541..7100 then 'an hour ago' # 3600 = 1 hour
            when 7101..82800 then ((a+99)/3600).to_i.to_s+' hours ago' 
            when 82801..172000 then 'a day ago' # 86400 = 1 day
            when 172001..518400 then ((a+800)/(60*60*24)).to_i.to_s+' days ago'
            when 518400..1036800 then 'a week ago'
            else ((a+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
        end
    end
end
  
Time.send :include, PrettyDate

# create managers
loanmgr = LoanManager.new
LoanApp.set :loanmgr, loanmgr

usermgr = UserManager.new
LoanApp.set :usermgr, usermgr

# register handlers
loanmgr.register("hdd", LoanHandler.new(Harddrive))

adminhandler = UserHandler.new(User, "admin")
adminhandler.permissions = [:create, :change, :invite, :delete]
usermgr.register("admin", adminhandler)

# temporary development stuff
unless Applock.first
    encrypted_password = BCrypt::Password.create("123")
    applock = Applock.new({:encrypted_password => encrypted_password})
    applock.save
end

run LoanApp