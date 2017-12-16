require_relative 'field'

class AbstractLoanable < ActiveRecord::Base
    has_many :loans, :as => :loanable
    after_initialize :set_getters_and_setters

    scope :not_deleted, ->{ where(:deleted => false) }

    scope :with_active_loans, ->{ where.not(:deleted => true, :active_loan_id => nil) }

    self.abstract_class = true

    @@loanable_name = nil
    @@fields = nil

    attr_reader :staticAttributes, :updateableAttributes

    # @abstract Subclass is expected to implement #set_getters_and_setters
    # @!method set_getters_and_setters
    #    Construction of getters and setters for fields associated
    #    with the specific loanable
    def set_getters_and_setters       
        raise InvalidSubclassExtension.new("set_getters_and_setters")
    end

    # @abstract Subclass is expected to implement #format_field
    # @!method format_field
    #    Takes raw field data and option and formats it
    def self.format_field(data, option)
        raise InvalidSubclassExtension.new("format_field")
    end

    def self.loanable_name
        @@loanable_name
    end

    def self.fields
        @@fields
    end

    def loanable_name
        @@loanable_name
    end

    def fields
        @@fields
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
    
end