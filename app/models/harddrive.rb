require_relative 'field'
require_relative 'loanable'

class Harddrive < ActiveRecord::Base
    include LoanableExtension

    @loanable_name = itself.to_s.downcase

    @fields = {
        "name" => Field.new(:text, "HDD name"),
        "status" => Field.new(:text, "Status"),
        "brand" => Field.new(:text, "Brand"),
        "disksize" => Field.new(:number, "Disksize", ["TB", "GB"]),
    }

    def self.format_field(field, data, option)
        formatted_data = data
        if field == "disksize" && option == "GB"
            formatted_data = data.to_f / 1000.0
        end
        formatted_data
    end

    def set_getters_and_setters
        @statusValues = ["ok", "unclear", "broken"]

        @staticAttributes = {
            "name" => ->{"#{self.name}"},
            "status" => ->{(["#{self.status}"] + @statusValues).uniq},
            "brand" => ->{"#{self.brand}"},
            "disksize" => ->{"#{self.disksize} TB"},
        }

        @updateableAttributes = {"status" => ->(value){self.status = value}}

        @values = {
            "name" => Datafield.new(->{self.name}),
            "status" => Datafield.new(->{self.status}),
            "brand" => Datafield.new(->{self.brand}),
            "disksize" => Datafield.new(->{self.disksize.to_f * 1000.0}, "GB"),
        }
        
        # for mobile
        @subtitle1 = ->{"#{self.brand}"} 
        @subtitle2 = ->{"status: #{self.status}"}
        @hidden_label = "Disksize"
        @hidden_content = ->{"#{self.disksize}TB"}
    end

end