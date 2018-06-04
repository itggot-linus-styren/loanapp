class LoanHandler
    
    attr_reader :loanable

    def initialize(loanable)
        @loanable = loanable
    end

    def find(id)
        @loanable.find_by_id(id)
    end

    def find_by_name(name)
        @loanable.find_by_name(name)
    end

    def make_loan(loanable, loan)
        loan = Loan.new(loan)
        loan.loanable = loanable
        loan.save
    end

    def return_loan(loan, values)
        loan.loanable.updateableAttributes.each do |name, setter|
            setter.call(values["new_#{name}"])
        end
        loan.returned_at = Time.now
        loan.loanable.save
        loan.save
    end

    def is_loaned?(loanable)        
        Loan.where("loanable_type LIKE ? AND loanable_id = ? AND returned_at IS NULL", loanable.loanable_name, loanable.id).any?
    end

end