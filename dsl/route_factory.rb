module RouteFactory
    @registry = {}
    @attributes = {}
    @set_attributes = {}
  
    def self.registry
        @registry
    end

    def self.attributes
        @attributes
    end

    def self.set_attributes
        @set_attributes
    end
  
    def self.define(&block)
        definition_proxy = DefinitionProxy.new
        definition_proxy.instance_eval(&block)
    end
  
    def self.build(controller, factory_def, args)
        @attributes.clear

        resource = factory_def[0].to_s
        is_required = factory_def[1]

        vars = {}
        controller.instance_variables.each do |var|
            key = var.to_s.gsub("@", "").to_sym
            vars[key] = controller.instance_variable_get(var)
        end
        @attributes.merge!(vars)

        begin            
            registry[resource.to_sym].call(*args) # updates set_attributes
        rescue RouteDefError
            raise if is_required
        end

        @set_attributes&.each do |attribute_name, value|
            controller.instance_variable_set("@#{attribute_name}", value)
        end
    end
end
  
class DefinitionProxy
    def factory(factory_def, &block)
        RouteFactory.registry[factory_def] = block.to_proc
    end

    def method_missing(method, *args)    
        raise ArgumentError, "Missing method #{method}" if  !RouteFactory.attributes.key?(method) &&
                                                            !RouteFactory.registry.include?(method)

        unless RouteFactory.attributes.key?(method)
            attributes = RouteFactory.registry[method].call(*args)
            RouteFactory.attributes.merge!(attributes)
        end

        RouteFactory.attributes[method]
    end

    def factory_set(attributes)
        RouteFactory.set_attributes.merge!(attributes)
    end
end

class RouteDefError < StandardError
    
    attr_accessor :message
    
    def initialize(err_msg)
        @message = err_msg
    end
end