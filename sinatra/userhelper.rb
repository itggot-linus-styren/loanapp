require 'sinatra/base'

module Sinatra
    module UserHelper

        def loginapp_route(params)
            applock = Applock.first
            encrypted_password = BCrypt::Password.new(applock.encrypted_password)
            if encrypted_password == params[:password]
                session[:permitted] = true
            else
                flash[:error] = "Invalid password."                
            end
            redirect '/'
        end

        def login_route(usermgr, params)
            @usertype = params[:usertype]
            if usermgr.has_association(@usertype)
                session[:usertype] = @usertype
                slim :'user/login'
            else
                flash[:error] = "The user type \"#{@usertype}\" does not exist!"
                redirect redirect_to_back_or_default
            end
        end

        def logout_route
            session[:user_id] = nil
            redirect '/'
        end

        def authentication_route(usermgr, params)
            credentials = params[:login]
            type = session[:usertype]

            unless usermgr.has_association(type)
                flash[:error] = "The usertype \"#{type}\" is unknown."
                has_error = true
            end
            if has_error || !type
                redirect "/"
            end

            has_error = validate_fields(credentials)

            unless has_error
                user_id, error = usermgr.authenticate(type, credentials)
                if user_id
                    session[:user_id] = user_id
                else
                    flash[:error] = error
                    has_error = true
                end
            end

            if has_error
                redirect redirect_to_back_or_default
            else
                redirect '/profile'
            end
        end

        def check_login
            userid = session[:user_id]

            if userid
                user = User.find(userid)
            end
            if !userid || !user
                flash[:error] = "You are not logged in."
                redirect redirect_to_back_or_default
            end

            user
        end

        def check_change_permission(usermgr, user)
            unless usermgr.has_permission?(user, :change)
                flash[:error] = "You do not have permission to change the app lock password."
                redirect redirect_to_back_or_default
            end
        end

        def profile_route(usermgr)
            @user = check_login

            @permissions = usermgr.userhandler_by_type(@user.user_type).permissions
            @usermgr = usermgr

            slim :'user/profile'
        end
        
        def change_route(usermgr)
            @user = check_login

            unless usermgr.has_permission?(@user, :change)
                flash[:error] = "You do not have permission to change the app lock password."
                redirect redirect_to_back_or_default
            end

            slim :'user/change'
        end

        def postchange_route(usermgr, params)
            @user = check_login
            check_change_permission(usermgr, @user)

            credentials = params[:change]
    
            has_error = validate_fields(credentials)

            unless has_error
                applock = Applock.first
                encrypted_password = BCrypt::Password.new(applock.encrypted_password)
                unless encrypted_password == credentials[:old_password]
                    flash[:error] = "The specified old password is incorrect."
                    has_error = true
                end
            end

            unless has_error
                if credentials[:password] != credentials[:confirm_password]
                    flash[:error] = "The passwords does not match!"
                    has_error = true
                end
            end

            unless has_error
                encrypted_password = BCrypt::Password.create(credentials[:password])
                Applock.update_all({:encrypted_password => encrypted_password})
            end

            if has_error
                redirect redirect_to_back_or_default
            else
                flash[:notify] = "The app lock password was changed successfully."
                redirect "/"
            end
        end

    end

    helpers UserHelper
end