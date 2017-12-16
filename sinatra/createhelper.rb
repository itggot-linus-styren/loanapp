require 'sinatra/base'
require 'sinatra/json'

module Sinatra
    module CreateHelper

        def add_route(loanmgr, usermgr, params)
            userid = session[:user_id]
            @type = params[:type]

            has_error = false
            if loanmgr.has_association(@type)
                @user = nil
                if userid
                    @user = User.find(userid)
                end
                if @user && usermgr.has_permission?(@user, :create)
                    @loanable = loanmgr.loanable_by_type(@type)
                else
                    flash[:error] = "You don't have permission to create a new loanable."
                    has_error = true
                end                
            else
                flash[:error] = "The loanable type \"#{@type}\" does not exist!"
                has_error = true
            end

            if has_error
                redirect redirect_to_back_or_default
            else
                slim :'loan/add'
            end
        end

        def delete_route(loanmgr, usermgr, params)
            userid = session[:user_id]
            type = params[:type]

            has_error = false
            if loanmgr.has_association(type)
                user = nil
                if userid
                    user = User.find(userid)
                end                
                if user && usermgr.has_permission?(user, :delete)
                    loanable = loanmgr.loanable_by_type(type)
                else
                    error = "You don't have permission to delete."
                    has_error = true
                end                
            else
                error = "The loanable type \"#{@type}\" does not exist!"
                has_error = true
            end

            unless has_error
                loanable_to_delete = loanable.find_by_id(params[:id])
                unless loanable_to_delete
                    error = "The #{loanable.loanable_name} does not exist."
                    has_error = true
                end
            end

            unless has_error
                if loanmgr.is_loaned?(type, loanable_to_delete)
                    error = "#{loanable_to_delete.name.capitalize} is loaned and can't be deleted."
                    has_error = true
                end
            end

            if has_error
                json :successful => 'false', :error => error
            else
                loanable_to_delete.deleted = true                
                if loanable_to_delete.save
                    json :successful => 'true'
                else
                    json :successful => 'false', :error => "Something went wrong when trying to delete #{loanable_to_delete.name}."
                end
            end
        end

        def postcreate_route(loanmgr, params)
            form = params[:create]
            name = form[:name]
            type = session[:type]

            has_error = false
            unless loanmgr.has_association(type)
                flash[:error] = "The loan type \"#{type}\" is unknown."
                has_error = true
            end
            if has_error || !type
                redirect "/"
            end

            has_error = validate_fields(form)

            unless has_error
                loanable = loanmgr.loanable_by_type(type)
                loanable_name = loanable.loanable_name
        
                loanable_by_name = loanmgr.find_by_name(type, name)
                if loanable_by_name && !loanable_by_name.deleted
                    flash[:error] = "This #{loanable_name} already exists in the database."
                    has_error = true
                end
            end

            unless has_error
                params[:create][:deleted] = false
                if params[:options]
                    loanable.fields.each do |name, _|
                        if params[:options][name]
                            params[:create][name] = loanable.format_field(name, params[:create][name], params[:options][name])
                        end
                    end
                end
                newloanable = loanable.find_or_initialize_by(:name => name).update!(params[:create])
    
                unless newloanable
                    flash[:error] = "Sorry, there was an error creating the #{loanable_name}."
                    has_error = true
                end
            end
    
            if has_error
                redirect redirect_to_back_or_default
            else
                flash[:notify] = "The #{loanable_name} \"#{name}\" was successfully added to the database."
                redirect "/"
            end
        end
        
    end

    helpers CreateHelper
end