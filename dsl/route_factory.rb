module RouteFactory
    @registry = {}
  
    def self.registry
        @registry
    end
  
    def self.define(&block)
        definition_proxy = DefinitionProxy.new
        definition_proxy.instance_eval(&block)
    end
  
    def self.build(controller, factory_def, *args)
        def_method = registry[factory_def].call(*args) # TODO invoke method properly
        attributes = factory.attributes.merge(overrides)
        attributes.each do |attribute_name, value|
            controller.instance_variable_set("@#{attribute_name}", value)
        end
    end
end
  
class DefinitionProxy
    def factory(factory_def, &block) # TODO: replace with lambda if not working
        RouteFactory.registry[factory_def] = block.to_proc
    end
end