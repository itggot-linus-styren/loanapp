class Field

    attr_reader :type, :description, :options
    attr_accessor :value, :selected

    def initialize(type, description, options = false)
        @type = type
        @description = description
        @options = options
    end

end

class Datafield

    attr_reader :option
    
    def initialize(value, option = nil)
        @value = value
        @option = option
    end

    def value
        @value.call
    end

end