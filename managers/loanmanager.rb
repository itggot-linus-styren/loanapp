require_relative 'manager'

class LoanManager < Manager

    def initialize
        super()        
        @methods += [:make_loan, :return_loan, :is_loaned?]
    end

    def make_loan(type, id, loan)
        if @associations[type]
            @associations[type].make_loan(id, loan)
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

    def loanable_by_type(type)
        if @associations[type]
            @associations[type].loanable
        else
            raise NoHandlerError.new(type)
        end
    end

end