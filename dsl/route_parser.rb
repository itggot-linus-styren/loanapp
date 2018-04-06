require 'singleton'

class RouteParser
    include Singleton

    def load(routes)
        # load routes from routes.yml file
    end

    def fetch_defs(controller_name)
        # check if controller_name is viewcontroller or actioncontroller and return list of defs + perms
        defs, perms
    end
end