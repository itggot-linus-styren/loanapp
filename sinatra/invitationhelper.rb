require 'sinatra/base'

module Sinatra
    module InvitationHelper

        def invite_route(usermgr)
            userid = session[:user_id]

            @user = nil
            if userid
                @user = User.find(userid)
            end
            if @user && usermgr.has_permission?(@user, :invite)
                @usermgr = usermgr
                slim :'user/invite'
            else
                flash[:error] = "You don't have permission to create an invite."
                redirect redirect_to_back_or_default
            end
        end

        def invited_route(params)
            userid = session[:user_id]
            token = params[:token]

            has_error = false
            invitation = nil
            if userid
                user = User.find_by_id(userid)                
                invitation = Invitation.find_by_token(token)
                unless invitation
                    flash[:error] = "Invitation with token \"#{token}\" does not exist."
                    has_error = true
                else
                    if user && invitation.invited_by == user
                        @invitation_url = "/invite/#{invitation.token}"
                    else
                        flash[:error] = "This invitation was not created by you."
                        has_error = true
                    end
                end
            else
                flash[:error] = "You are not logged in."
                has_error = true
            end

            if has_error
                redirect '/'
            else
                slim :'user/invited'
            end
        end

        def claim_invite_route(usermgr, params)
            @invitation = Invitation.claimable.where(:token => params[:token]).first
            if @invitation
                session[:token] = @invitation.token
                slim :'user/register'
            else
                flash[:error] = "Invitation with token \"#{params[:token]}\" does not exist - it has expired, is invalid or has already been claimed."
                redirect '/'
            end
        end

        def postregister_route(params)
            token = session[:token]
            dev = session[:dev] #temporary
            
            if !token && !dev
                redirect '/'
            end

            #temporary
            if !dev
                @invitation = Invitation.claimable.where(:token => token).first
                if @invitation
                    usertype = @invitation.user_type
                else
                    flash[:error] = "Invitation with token \"#{token}\" is invalid."
                    redirect redirect_to_back_or_default
                end
            else
                usertype = "admin"
            end

            credentials = params[:register]
    
            has_error = validate_fields(credentials)

            unless has_error
                if credentials[:password] != credentials[:confirm_password]
                    flash[:error] = "The passwords does not match!"
                    has_error = true
                end
            end

            unless has_error
                username = credentials[:username]
                password = credentials[:password]
                encrypted_password = BCrypt::Password.create(password)

                other_user = User.find_by_username_nocase(username)
                if other_user.any?
                    flash[:error] = "The user \"#{other_user.first.username}\" already exists."
                    has_error = true
                else
                    user = User.new({:username => username, :user_type => usertype, :encrypted_password => encrypted_password})        
                    unless user.save
                        flash[:error] = "Something went wrong creating the user."
                        has_error = true
                    end
                end
            end

            if has_error
                redirect redirect_to_back_or_default
            else
                # temporary
                if @invitation
                    puts "Set used_by to " + user.username
                    @invitation.update(:used_by => user)
                end
                flash[:notify] = "The user \"#{username}\" was successfully registred."
                redirect "/"
            end
        end

        def postinvite_route(usermgr, params)
            userid = session[:user_id]

            has_error = false
            @user = nil
            if userid
                @user = User.find(userid)
            end
            if @user && usermgr.has_permission?(@user, :invite)
                usertype = params[:usertype]
                if usertype
                    invite = Invitation.new({:user_type => usertype})
                    invite.invited_by = @user
                    invite.save
                else
                    flash[:error] = "You must specify an account type."
                    has_error = true
                end
            else
                flash[:error] = "You don't have permission to create an invite."
                has_error = true
            end

            if has_error
                redirect redirect_to_back_or_default
            else
                redirect "/invited/#{invite.token}"
            end
        end
        
    end

    helpers InvitationHelper
end