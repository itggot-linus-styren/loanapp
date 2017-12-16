require_relative 'field'
require_relative 'loanable'

class Harddrive < ActiveRecord::Base
    include LoanableExtension

    @loanable_name = itself.to_s.downcase

    @fields = {
        "name" => Field.new(:text, "HDD name"),
        "brand" => Field.new(:text, "Brand"),
        "disksize" => Field.new(:number, "Disksize", ["TB", "GB"]),
        "status" => Field.new(:text, "Status")
    }

    def self.format_field(field, data, option)
        formatted_data = data
        if field == "disksize" && option == "GB"
            formatted_data = data.to_f / 1000.0
        end
        formatted_data
    end

    def set_getters_and_setters       
        @staticAttributes = {
            "name" => ->{"#{self.name}"},
            "brand" => ->{"#{self.brand}"},
            "disksize" => ->{"#{self.disksize} TB"},
            "status" => ->{"#{self.status}"}
        }

        @updateableAttributes = {"status" => ->(value){self.status = value}}
        
        # for mobile
        @subtitle1 = ->{"#{self.brand}"} 
        @subtitle2 = ->{"status: #{self.status}"}
        @hidden_label = "Disksize"
        @hidden_content = ->{"#{self.disksize}TB"}
    end

end