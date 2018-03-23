require_relative 'controller.rb'

class LoginAppController < Controller
    def index(params)        
        encrypted_password = BCrypt::Password.new(Applock.first.encrypted_password)
        if encrypted_password == params[:password]
            @ctx.session[:permitted] = true
        else
            @ctx.flash[:error] = "Invalid password."                
        end
        @ctx.redirect '/'
    end

    def change(params)
        credentials = params[:change]

        @ctx.validate_fields(credentials) || abort_route

        encrypted_password = BCrypt::Password.new(Applock.first.encrypted_password)
        encrypted_password == credentials[:old_password] || abort_route do
            @ctx.flash[:error] = "The specified old password is incorrect."
        end

        credentials[:password] != credentials[:confirm_password] || abort_route do
            @ctx.flash[:error] = "The passwords does not match!"
        end

        encrypted_password = BCrypt::Password.create(credentials[:password])
        Applock.update_all({:encrypted_password => encrypted_password})

        @ctx.flash[:notify] = "The app lock password was changed successfully."
        @ctx.redirect '/'
    end
end

class LoginAppViewController < ViewController
    def index
        :'index', {}
    end

    # TODO: in DSL system, the @user must be set
    def change
        :'user/change', {:user => @user}
    end
end