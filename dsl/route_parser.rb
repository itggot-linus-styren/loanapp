require 'singleton'
require 'yaml'

class RouteParser
    include Singleton

    def load(filename)
        # load routes from routes.yml file
        @routes = YAML.load_file(filename)
    end

    def fetch_defs(route_name, controller)
        controller_name = controller.name
        
        # check if controller_name is viewcontroller or actioncontroller and return list of defs + perms
        if controller < ViewController
            resource_name = controller_name.downcase.chomp("viewcontroller")
            resource_type = "views"
        elsif controller < Controller
            resource_name = controller_name.downcase.chomp("controller")
            resource_type = "actions"
        else
            raise InvalidControllerType, controller_name
        end

        if  !@routes["routes"].include?(resource_name) ||
            !@routes["routes"][resource_name].include?(resource_type) ||
            !@routes["routes"][resource_name][resource_type].include?(route_name)
            return [], []
        end

        route = @routes["routes"][resource_name][resource_type][route_name]
        defs = route["wants"]&.map {|k| [k, true] } || []
        defs.concat(route["optional"]&.map {|k| [k, false] } || [])
        perms = route["permissions"]

        if perms && !route["wants"]&.include?("user")
            defs << ["user", true]
        end

        return defs, perms
    end
end