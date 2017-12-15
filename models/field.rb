class Field

    attr_reader :type, :description

    def initialize(type, description)
        @type = type
        @description = description
    end

end