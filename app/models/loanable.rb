require_relative 'field'

module LoanableExtension

    extend ActiveSupport::Concern

    included do
        has_many :loans, :as => :loanable
        after_initialize :set_getters_and_setters

        scope :not_deleted, ->{ where(:deleted => false) }
    end

    @loanable_name = nil
    @fields = nil

    attr_reader :staticAttributes, :updateableAttributes, :values, :statusValues

    def loaned_count
        Loan.for_loanable_type(self.class).where(:loanable_id => self.id).count
    end

    def loanable_name
        self.class.loanable_name
    end

    def fields
        self.class.fields
    end
    
    def subtitle1
        @subtitle1.call
    end

    def subtitle2
        @subtitle2.call
    end

    def hidden_label
        @hidden_label
    end

    def hidden_content
        @hidden_content.call
    end

    class_methods do

        def loanable_name
            @loanable_name
        end

        def fields
            @fields
        end
    end
    
end

#ActiveRecord::Base.send(:include, LoanableExtension)