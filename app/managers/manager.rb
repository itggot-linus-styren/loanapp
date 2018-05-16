class Manager

    attr_reader :associations

    def initialize
        @associations = {}
        @methods = [:find, :find_by_name]
    end

    def register(type, handler)
        @methods.each do |method|
            unless handler.respond_to?(method)
                raise InvalidHandlerError.new(method)
            end
        end
        @associations[type] = handler
    end

    def has_association(type)
        !!@associations[type]
    end
    
    def find(type, id)
        if @associations[type]
            @associations[type].find(id)
        else
            raise NoHandlerError.new(type)
        end
    end

    def find_by_name(type, name)
        if @associations[type]
            @associations[type].find_by_name(name)
        else
            raise NoHandlerError.new(type)
        end
    end

end