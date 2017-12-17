require_relative 'field'
require_relative 'loanable'

class Car < ActiveRecord::Base
    include LoanableExtension

    @loanable_name = itself.to_s.downcase

    @fields = {
        "name" => Field.new(:text, "Car registration number"),
        "brand" => Field.new(:text, "Brand"),
        "status" => Field.new(:text, "Status")
    }

    def set_getters_and_setters       
        @staticAttributes = {
            "name" => ->{"#{self.name}"},
            "brand" => ->{"#{self.brand}"},
            "status" => ->{"#{self.status}"}
        }

        @updateableAttributes = {"status" => ->(value){self.status = value}}

        @values = {
            "name" => Datafield.new(->{self.name}),
            "brand" => Datafield.new(->{self.brand}),
            "status" => Datafield.new(->{self.status})
        }

        # for mobile
        @subtitle1 = ->{"#{self.brand}"} 
        @subtitle2 = ->{"status: #{self.status}"}
        @hidden_label = ""
        @hidden_content = ->{""}
    end

end