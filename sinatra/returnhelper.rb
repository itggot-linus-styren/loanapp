require 'sinatra/base'

module Sinatra
    module ReturnHelper

        def return_route(loanmgr, params)
            id = params[:id]
            type = params[:type]
            @loan = Loan.find(id)

            unless @loan
                flash[:notify] = "No such loan exists!"
                redirect '/'
            end
            
            session[:loanid] = id
            session[:type] = type
            slim :'loan/return'
        end

        def postreturn_route(loanmgr, params)
            id = session[:loanid]
            type = session[:type]
            
            unless id && type
                redirect '/'
            end
    
            form = params[:return]
            
            has_error = validate_fields(form)
    
            loan = Loan.find(id)
            unless loan
                redirect '/'
            end
    
            responsible = form[:responsible]
    
            if !has_error && !loan.responsible.similar?(responsible)
                flash[:error] = "The responsible person \"#{responsible}\" does not match the person recorded in the database: \"#{loan.responsible}.\""
                has_error = true
            end
    
            loanable_name = loan.loanable.loanable_name
            name = loan.loanable.name
            if !has_error && loanmgr.return_loan(type, loan, form)                
                flash[:notify] = "The #{loanable_name} \"#{name}\" was successfully returned."                
            end
    
            if has_error
                redirect redirect_to_back_or_default
            else
                redirect '/'
            end
        end
        
    end

    helpers ReturnHelper
end