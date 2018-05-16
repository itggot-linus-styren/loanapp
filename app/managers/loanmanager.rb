require_relative 'manager'

class LoanManager < Manager

    def initialize
        super()        
        @methods += [:make_loan, :return_loan, :is_loaned?]
    end

    def make_loan(type, loanable, loan)
        if @associations[type]
            @associations[type].make_loan(loanable, loan)
        else
            raise NoHandlerError.new(type)
        end
    end

    def return_loan(type, loan, values)
        if @associations[type]
            @associations[type].return_loan(loan, values)
        else
            raise NoHandlerError.new(type)
        end
    end

    def is_loaned?(type, loanable)
        if @associations[type]
            @associations[type].is_loaned?(loanable)
        else
            raise NoHandlerError.new(type)
        end
    end

    def not_deleted?(type, name)
        if @associations[type]
            loanable_by_name = @associations[type].find_by_name(name)
            loanable_by_name && !loanable_by_name.deleted
        else
            raise NoHandlerError.new(type)
        end
    end

    def loanable_by_type(type)
        if @associations[type]
            @associations[type].loanable
        else
            raise NoHandlerError.new(type)
        end
    end

end