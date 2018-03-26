require_relative 'imports.rb'

# create managers
loanmgr = LoanManager.new
LoanApp.set :loanmgr, loanmgr

usermgr = UserManager.new
LoanApp.set :usermgr, usermgr

# register handlers
loanmgr.register("hdd", LoanHandler.new(Harddrive))
loanmgr.register("car", LoanHandler.new(Car))

adminhandler = UserHandler.new(User, "admin")
adminhandler.permissions = [:create, :update, :change, :invite, :delete]
usermgr.register("admin", adminhandler)

# temporary development stuff
unless Applock.first
    encrypted_password = BCrypt::Password.create("123")
    applock = Applock.new({:encrypted_password => encrypted_password})
    applock.save
end

run LoanApp