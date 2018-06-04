require_relative '../../dsl/route_factory.rb'

RouteFactory.define do

    factory :loan do |params, _|
        if params[:id]
            loan = Loan.find(params[:id])
            raise RouteDefError, "The loan with ID #{params[:id]} doesn't exist." if !loan || !loan.loanable

            factory_set({:loan => loan, :type => params[:type]})
        end
    end

    factory :loanable do |params, _|
        _loanable_type = loanable_type(params, _)
        if _loanable_type && params[:id]
            loanable = loanmgr.find(params[:type], params[:id])        
            raise RouteDefError, "The #{_loanable_type.loanable_name} doesn't exist or is deleted." if !loanable || loanable.deleted

            factory_set({:loanable => loanable, :type => params[:type]})
        end
    end

    factory :loanable_type do |params, _|    
        type = params[:type]
        if type
            raise RouteDefError, "The loanable type \"#{type}\" does not exist!" unless loanmgr.has_association(type)        
            
            factory_set({:loanable_type => loanmgr.loanable_by_type(type), :type => type})
        end
    end
end