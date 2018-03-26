class UserHandler
    
    attr_reader :type
    attr_accessor :permissions

    def initialize(user, type)
        @user = user
        @type = type
        @permissions = []
    end

    def find(id)
        @user.for_user_type(type).where(:id => id).first
    end

    def find_by_name(name)
        @user.for_user_type(type).where(:username => name).first
    end

    def authenticate(credentials)
        username = credentials['username']
        password = credentials['password']

        user = find_by_name(username)
        if user
            encrypted_password = BCrypt::Password.new(user.encrypted_password)

            if encrypted_password == password
                return user.id, ""
            else
                return false, "Invalid password."
            end
        else
            return false, "The user \"#{username}\" does not exist."
        end
    end

    def has_permission?(permission)
        @permissions.include? permission
    end

end