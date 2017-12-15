require_relative 'manager'

class UserManager < Manager

    def initialize
        super()        
        @methods += [:authenticate, :has_permission?]
    end

    def authenticate(type, credentials)
        if @associations[type]
            @associations[type].authenticate(credentials)
        else
            raise NoHandlerError.new(type)
        end
    end

    def has_permission?(user, permission)
        type = user.user_type
        if @associations[type]
            @associations[type].has_permission?(permission)
        else
            raise NoHandlerError.new(type)
        end
    end

    def userhandler_by_type(type)
        if @associations[type]
            @associations[type]
        else
            raise NoHandlerError.new(type)
        end
    end

end