require_relative 'controller.rb'

class InvitesController < Controller
    # TODO: set in DSL
    def new(params)
        invitation = params[:invitation] # TODO: change form to array
        
        @ctx.validate_fields(invitation) || abort_route

        invite = Invitation.new(invitation)
        invite.invited_by = @user
        invite.save

        @ctx.redirect "/invites/#{invite.token}"
    end
end

class InvitesViewController < ViewController
    def index(params)
        token = params[:token]

        invitation = Invitation.find_by_token(token) || abort_route do
            "Invitation with token \"#{token}\" does not exist."
        end

        puts @user.inspect
        
        invitation.invited_by == @user || abort_route do
            "This invitation was not created by you."
        end

        return :'user/invited', {:invitation_url => "/invites/#{invitation.token}/claim"}
    end

    def new
        return :'user/invite', {}
    end

    def claim(params)
        token = params[:token]

        invitation = Invitation.claimable.where(:token => token).first || abort_route do
            "Invitation with token \"#{token}\" does not exist - it has expired, is invalid or has already been claimed."
        end

        @ctx.session[:token] = invitation.token
        @ctx.session[:permitted] = true

        return :'user/register', {:invitation => invitation}
    end
end