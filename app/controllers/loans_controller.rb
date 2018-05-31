require_relative 'controller.rb'

class LoansController < Controller

    def loan(params)
        loanable_type = params[:type]
        loan = params[:loan]

        !@loanmgr.is_loaned?(loanable_type, @loanable) || abort_route do
            "\"#{@loanable.name}\" is already loaned!"
        end
        
        @ctx.validate_fields(loan) || abort_route

        @loanmgr.make_loan(loanable_type, @loanable, loan) || abort_route do
            'Sorry, there was an error making the loan.'
        end

        @ctx.redirect "/loans?type=#{loanable_type}&responsible=#{URI.encode loan[:responsible]}"
    end

    def new(params)
        creation = params[:create]
        name = creation[:name]

        @ctx.validate_fields(creation) || abort_route

        !@loanmgr.not_deleted?(params[:type], name) || abort_route do
            "The #{@loanable_type.loanable_name} \"#{name}\" already exists in the database."
        end

        create_or_update(@loanable_type, params, name) || abort_route do
            "Sorry, there was an error creating the #{@loanable_type.loanable_name}."
        end

        @ctx.flash[:notify] = "The #{@loanable_type.loanable_name} \"#{name}\" was successfully added to the database."
        @ctx.redirect_to_back_or_default
    end
    
    def edit(params)
        creation = params[:create]
        name = creation[:name]

        @ctx.validate_fields(creation) || abort_route

        !@loanmgr.is_loaned?(@type, @loanable) || abort_route do
            "#{@loanable.name.capitalize} is loaned and can't be updated."
        end

        create_or_update(@loanable_type, params, @loanable.name) || abort_route do
            "Sorry, there was an error creating the #{@loanable_type.loanable_name}."
        end

        @ctx.flash[:notify] = "The #{@loanable_type.loanable_name} \"#{name}\" was successfully edited."
        @ctx.redirect_to_back_or_default
    end

    def delete(params)
        if @loanmgr.is_loaned?(@type, @loanable)
            @ctx.json :successful => 'false', :error => "#{@loanable.name.capitalize} is loaned and can't be deleted."
        end

        @loanable.deleted = true
        unless @loanable.save
            @ctx.json :successful => 'false', :error => "Something went wrong when trying to delete #{@loanable.name}."
        end

        @ctx.json :successful => 'true'
    end

    def return(params)
        returnation = params[:return]
        
        @ctx.validate_fields(returnation) || abort_route

        responsible = returnation[:responsible]
        @loan.responsible.similar?(responsible) || abort_route do
           "The responsible person \"#{responsible}\" does not match the person recorded in the database: \"#{@loan.responsible}.\""
        end
        loanable_name = @loan.loanable.loanable_name
        name = @loan.loanable.name
        @loanmgr.return_loan(@type, @loan, returnation) || abort_route do
            "An error occured when returning the #{loanable_name} \"#{name}\"."
        end
        
        @ctx.flash[:notify] = "The #{loanable_name} \"#{name}\" was successfully returned."
        @ctx.redirect "/loans/#{@type}/view"
    end

    private

    def create_or_update(loanable_type, params, name)
        options = params[:options]
        creation = params[:create]

        creation[:deleted] = false
        if options
            loanable_type.fields.each do |name, _|
                if options[name]
                    creation[name] = loanable_type.format_field(name, creation[name], options[name])
                end
            end
        end

        loanable_type.find_or_initialize_by(:name => name).update!(creation)
    end
end

class LoansViewController < ViewController

    def index(params)
        if params[:type] && params[:responsible]
            loans = Loan.with_active_loans(@loanable_type).where("responsible LIKE ?", "%#{params[:responsible]}%").order("loans.responsible ASC")
        elsif params[:type]
            loans = Loan.with_active_loans(@loanable_type).order("loans.responsible ASC")
        else
            associations = @loanmgr.associations
            # change from loantypes to loanable_types in slim
            loanable_types = associations.keys.map do |type|
                name = associations[type].loanable.loanable_name
                available_count = @loanmgr.loanable_by_type(type).not_deleted.where.not(:id => Loan.with_active_loans(associations[type].loanable).pluck(:loanable_id)).length
                [type, name, available_count]
            end
            return :'loan/loanables', {:loanable_types => loanable_types}
        end
        return :'loan/loans', {:loans => loans, :type => params[:type]}
    end

    def view(params)
        loanables = @loanable_type.not_deleted.where.not(:id => Loan.with_active_loans(@loanable_type).pluck(:loanable_id))
        return :'loan/view', {:loanables => loanables}
    end    

    def loan(params)
        return :'loan/loan', {}
    end

    def new(params)
        return :'loan/new', {}
    end
    
    def edit(params)
        return :'loan/edit', {}
    end

    def return(params)
        return :'loan/return', {}
    end
end