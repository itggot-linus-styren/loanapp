require 'sinatra/base'

module Sinatra
    module LoanHelper

        def index_route
            if session[:permitted]
                type = session[:type]
                if type
                    redirect "/view/#{type}"
                else
                    redirect "/loans"
                end
            else
                slim :'index', :layout => false
            end
        end

        def loan_route(loanmgr, params)
            id = params[:id]
            @type = params[:type]

            if loanmgr.has_association(@type)
                @loanable = loanmgr.find(@type, id)
                if @loanable
                    if @loanable.deleted
                        flash[:error] = "The #{@loanable.loanable_name} \"#{@loanable.name}\" is deleted."
                        has_error = true
                    else
                        unless loanmgr.is_loaned?(@type, @loanable)
                            session[:loanid] = id
                            session[:type] = @type       
                        else
                            flash[:error] = "The #{@loanable.loanable_name} \"#{@loanable.name}\" is already loaned."
                            has_error = true
                        end
                    end
                else
                    flash[:error] = "No such loanable exists."
                    has_error = true
                end
            else
                flash[:error] = "The loanable type \"#{@type}\" does not exist!"
                has_error = true
            end

            if has_error
                redirect redirect_to_back_or_default
            else
                slim :'loan/loan'
            end
        end

        def loans_by_responsible_route(loanmgr, params)
            @type = params[:type]
            if loanmgr.has_association(@type)
                @loanable = loanmgr.loanable_by_type(@type)
                @loans = Loan.with_active_loans(@loanable).where("responsible LIKE ?", "%#{params[:responsible]}%").order("loans.responsible ASC")               
                slim :'loan/loans'
            else
                flash[:error] = "The loanable type \"#{@type}\" does not exist!"
                redirect redirect_to_back_or_default
            end
        end

        def loans_by_type_route(loanmgr, params)
            @type = params[:type]
            if loanmgr.has_association(@type)
                @loanable = loanmgr.loanable_by_type(@type)
                @loans = Loan.with_active_loans(@loanable).order("loans.responsible ASC")
                slim :'loan/loans'
            else
                flash[:error] = "The loanable type \"#{@type}\" does not exist!"
                redirect redirect_to_back_or_default
            end
        end

        def loans_route(loanmgr)
            associations = loanmgr.associations
            @loantypes = associations.keys.map do |type|
                name = associations[type].loanable.loanable_name
                availableCount = loanmgr.loanable_by_type(type).not_deleted.where.not(:id => Loan.with_active_loans(@loanable).pluck(:loanable_id)).length
                [type, name, availableCount]
            end         
            slim :'loan/loanables'
        end

        def view_route(loanmgr, usermgr, params)
            @type = params[:type]
            @usermgr = usermgr
            if loanmgr.has_association(@type)
                @loanable = loanmgr.loanable_by_type(@type)
                @loanables = @loanable.not_deleted.where.not(:id => Loan.with_active_loans(@loanable).pluck(:loanable_id))
                #@loanables = @loanable.joins(:loans).where.not("#{@loanable.loanable_name}s.id = loans.loanable_id AND loans.returned_at IS NULL")
                session[:type] = @type

                @has_create_permission = false
                @has_delete_permission = false
                @has_update_permission = false
                @show_context = false
                if session[:user_id]
                    @user = User.find(session[:user_id])
                    @has_create_permission = @usermgr.has_permission?(@user, :create)
                    @has_delete_permission = @usermgr.has_permission?(@user, :delete)
                    @has_update_permission = @usermgr.has_permission?(@user, :update)
                    @show_context = true
                end

                slim :'loan/view'
            else
                flash[:error] = "The loanable type \"#{@type}\" does not exist!"
                redirect redirect_to_back_or_default
            end
        end

        def makeloan_route(loanmgr, params)
            id = session[:loanid]
            type = session[:type]
            
            has_error = false
            unless loanmgr.has_association(type)
                flash[:error] = "The loan type \"#{type}\" is unknown."
                has_error = true
            end
            if has_error || !id || !type
                redirect '/'
            end
    
            form = params[:loan]
    
            has_error = validate_fields(form)

            unless has_error
                @loanable = loanmgr.find(type, id)
                unless @loanable
                    flash[:error] = "This loanable does not exist."
                    has_error = true
                end
            end
    
            unless has_error
                if loanmgr.is_loaned?(type, @loanable)
                    flash[:error] = "This #{@loanable.loanable_name} is already loaned and is not available!"
                    has_error = true
                end
            end

            unless has_error
                if @loanable.deleted
                    flash[:error] = "This #{@loanable.loanable_name} is deleted"
                    has_error = true
                end
            end
    
            if !has_error && !loanmgr.make_loan(type, id, form)
                flash[:error] = 'Sorry, there was an error making the loan.'
                has_error = true            
            end
    
            if has_error
                redirect redirect_to_back_or_default
            else
                redirect "/loans/#{type}/#{URI.encode form[:responsible]}"
            end
        end

        def validate_fields(form)
            form.each do |field, value|
                if value.blank?
                    flash[:error] = "You must fill in the field \"#{field}\"."
                    flash[:field] = field
                    return true
                end
            end
            return false
        end

    end

    helpers LoanHelper
end