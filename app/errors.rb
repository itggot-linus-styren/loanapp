class InvalidHandlerError < StandardError
    
    attr_accessor :message

    def initialize(method)
        @message = "Handler has not implemented method \"#{method}\""
    end
end

class NoHandlerError < StandardError
    
    attr_accessor :message

    def initialize(type)
        @message = "No handler registred for type \"#{type}\""
    end
end

class InvalidSubclassExtension < StandardError
    
    attr_accessor :message

    def initialize(method)
        @message = "Subclass has not implemented method \"#{method}\""
    end
end

class InvalidControllerType < StandardError
    
    attr_accessor :message
    
    def initialize(method)
        @message = "Controller of type \"#{method}\" is unknown"
    end
end