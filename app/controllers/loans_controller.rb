require_relative 'controller.rb'

class LoansController < Controller
    # TODO: expect DSL to have loanable set
    def loan(params)
        loanable_type = params[:type]
        loan = params[:loan]
        
        @ctx.validate_fields(loan) || abort_route

        @loanmgr.make_loan(loanable_type, @loanable, loan) || abort_route do
            flash[:error] = 'Sorry, there was an error making the loan.'
        end

        @ctx.redirect "/loans/?type=#{loanable_type}&responsible=#{URI.encode loan[:responsible]}"
    end

    # TODO: DSL should set @loanable_type
    def new(params)
        creation = params[:create]
        name = creation[:name]

        @ctx.validate_fields(creation) || abort_route

        loanmgr.not_deleted?(params[:type], name) || abort_route do
            flash[:error] = "The #{@loanable_type.loanable_name} \"#{name}\" already exists in the database."
        end

        create_or_update(@loanable_type, params, name) || abort_route do
            flash[:error] = "Sorry, there was an error creating the #{@loanable_type.loanable_name}."
        end

        flash[:notify] = "The #{loanable_name} \"#{name}\" was successfully added to the database."
        @ctx.redirect '/'
    end
    
    # TODO: DSL should set @loanable_type and @loanable
    def edit(params)
        creation = params[:create]
        name = creation[:name]

        @ctx.validate_fields(creation) || abort_route

        create_or_update(@loanable_type, params, @loanable.name) || abort_route do
            flash[:error] = "Sorry, there was an error creating the #{@loanable_type.loanable_name}."
        end

        flash[:notify] = "The #{loanable_name} \"#{name}\" was successfully added to the database."
        @ctx.redirect '/'
    end

    # TODO: DSL should set @loanable
    def delete(params)
        if loanmgr.is_loaned?(type, @loanable)
            json :successful => 'false', :error => "#{@loanable.name.capitalize} is loaned and can't be deleted."
        end

        @loanable.deleted = true
        unless @loanable.save
            json :successful => 'false', :error => "Something went wrong when trying to delete #{@loanable.name}."
        end

        json :successful => 'true'
    end

    # TODO: DSL should set @loan
    def return(params)
        returnation = params[:return]
        
        validate_fields(returnation) || abort_route

        responsible = returnation[:responsible]
        @loan.responsible.similar?(responsible) || abort_route do
            flash[:error] = "The responsible person \"#{responsible}\" does not match the person recorded in the database: \"#{@loan.responsible}.\""
        end
        loanable_name = @loan.loanable.loanable_name
        name = @loan.loanable.name
        loanmgr.return_loan(type, loan, form) || abort_route do
            flash[:notify] = "An error occured when returning the #{loanable_name} \"#{name}\"."
        end
        
        flash[:notify] = "The #{loanable_name} \"#{name}\" was successfully returned."
        @ctx.redirect '/'
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

    # TODO: expect DSL to have loanable_type set
    # Check conventions and readability of this method
    def index
        if params[:type] && params[:responsible]
            loans = Loan.with_active_loans(@loanable_type).where("responsible LIKE ?", "%#{params[:responsible]}%").order("loans.responsible ASC")
        elsif params[:type]
            loans = Loan.with_active_loans(@loanable_type).order("loans.responsible ASC")
        else
            associations = @loanmgr.associations
            # change from loantypes to loanable_types in slim
            loanable_types = associations.keys.map do |type|
                name = associations[type].loanable.loanable_name
                available_count = @loanmgr.loanable_by_type(type).not_deleted.where.not(:id => Loan.with_active_loans(@loanable).pluck(:loanable_id)).length
                [type, name, available_count]
            end
            return :'loan/loanables', {:loanable_types => loanable_types}
        end
        :'loan/loans', {:loans => loans, :type => params[:type]}
    end

    # TODO consider setting @type (params[:type]) in DSL

    # TOOD: expect DSL to set @loanable_type and @user (optionally?)
    def view(params)
        loanables = @loanable_type.not_deleted.where.not(:id => Loan.with_active_loans(@loanable).pluck(:loanable_id))
        :'loan/view', {:loanables => loanables, :type => params[:type]}
    end    

    # TODO: expect DSL to set @loanable
    def loan(params)
        :'loan/loan', {:type => params[:type]}
    end

    # TODO: expect DSL to set @loanable_type and @user
    def new(params)
        :'loan/new', {:type => params[:type]}
    end
    
    # TODO: expect DSL to set @loanable and @user
    def edit(params)
        :'loan/edit', {:type => params[:type]}
    end

    # TODO: expect DSL to set @loan
    def return(params)
        :'loan/return', {:type => params[:type]}
    end
end