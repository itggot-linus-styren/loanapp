require_relative 'field'
require_relative 'loanable'

class Car < ActiveRecord::Base
    include LoanableExtension

    @loanable_name = itself.to_s.downcase

    @fields = {
        "name" => Field.new(:text, "Car registration number"),
        "brand" => Field.new(:text, "Brand"),
        "status" => Field.new(:text, "Status", ["ok", "unclear", "broken"])
    }

    def set_getters_and_setters       
        @staticAttributes = {
            "name" => ->{"#{self.name}"},
            "brand" => ->{"#{self.brand}"},
            "status" => ->{(["#{self.status}"] + fields()["status"].options).uniq}
        }

        @updateableAttributes = {"status" => ->(value){self.status = value}}

        @values = {
            "name" => Datafield.new(->{self.name}),
            "brand" => Datafield.new(->{self.brand}),
            "status" => Datafield.new(->{self.status})
        }

        # TODO: consider https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel

        # for mobile
        @subtitle1 = ->{"#{self.brand}"} 
        @subtitle2 = ->{""}
    end

end