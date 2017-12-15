class Loan < ActiveRecord::Base
    belongs_to :loanable, :polymorphic => true
    #has_one :loan, :as => :loanable, :foreign_key => "active_loan_id"

    before_create :set_date_to_now
    def set_date_to_now
        self.loaned_at = Time.now
    end

    def loaned_at
        attributes['loaned_at'].to_pretty
    end

    scope :for_loanable_type, ->(class_name){ where("loanable_type = ?", class_name) }

    scope :with_active_loans, ->(class_name) { where("returned_at IS NULL") }
    #scope :active_loans_type, ->(class_name){ joins("INNER JOIN #{class_name}s ON (loanable_type = '#{class_name}' AND #{class_name}s.id = loanable_id AND #{class_name}s.active_loan_id IS NOT NULL)").includes(:loan, class_name) }
end

#Loan.includes(:loanable).where.not(:loanable => { active_loan_id: nil } )