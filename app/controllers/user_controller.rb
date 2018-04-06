require_relative 'controller.rb'

class UserController < Controller

    # TODO: in DSL make sure usermgr has association with @user_type
    def login
        credentials = params[:login]

        @ctx.validate_fields(credentials) || abort_route

        user_id, error = @usermgr.authenticate(@user_type, credentials)
        user_id || abort_route do
            flash[:error] = error
        end
        session[:user_id] = user_id
        
        @ctx.redirect '/user/profile'
    end

    def logout
        session[:user_id] = nil
        @ctx.redirect '/'
    end

    def register
        token = session[:token] || abort_route

        invitation = Invitation.claimable.where(:token => token).first || abort_route do
            flash[:error] = "Invitation with token \"#{token}\" is invalid."
        end

        usertype = invitation.user_type
        credentials = params[:register]

        @ctx.validate_fields(credentials) || abort_route

        credentials[:password] == credentials[:confirm_password] || abort_route do
            flash[:error] = "The passwords does not match!"
        end

        username = credentials[:username]
        password = credentials[:password]
        
        # TODO: check readability

        other_user = User.find_by_username_nocase(username)        
        other_user.any? && abort_route do
            flash[:error] = "The user \"#{other_user.first.username}\" already exists."
        end

        encrypted_password = BCrypt::Password.create(password)
        user = User.new({:username => username, :user_type => usertype, :encrypted_password => encrypted_password})        
        user.save || abort_route do
            flash[:error] = "Something went wrong creating the user."
        end

        invitation.update(:used_by => user)
        flash[:notify] = "The user \"#{username}\" was successfully registred."        
        @ctx.redirect '/'
    end    
end

class UserViewController < ViewController
    #TODO check for @user_type in DSL system
    def login
        :'user/login', {}
    end

    #TODO check for @user in DSL system
    def profile        
        permissions = @usermgr.userhandler_by_type(@user.user_type).permissions
        :'profile', {:permissions => permissions}
    end
end