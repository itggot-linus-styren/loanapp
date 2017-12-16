class Field

    attr_reader :type, :description, :options

    def initialize(type, description, options = false)
        @type = type
        @description = description
        @options = options
    end

end