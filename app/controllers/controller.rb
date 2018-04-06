require 'sinatra/base'

class Controller
    
    def initialize(ctx)
        @ctx = ctx
        @usermgr = ctx.settings.usermgr
        @loanmgr = ctx.settings.loanmgr        
    end

    def build_route(*args)
        # fetch defs from routes.yml
        defs, perms = RouteParser.instance.fetch_defs(self.class.name)

        # merge permissions with params args
        args << perms

        # build defs and set instance variables
        defs.each do |route_def|
            RouteFactory.build(self, route_def, *args) # TODO make sure exceptions are handled
        end
    end

    def abort_route(&block)
        yield if block_given?
        redirect redirect_to_back_or_default
    end

    def dispatch(action, *args)
        build_route(args) # exceptions
        self.send(action, *args)
    end

    def self.action(action_name, env, *args)
        -> (env) { self.new(env).dispatch(action_name, args) }
    end

end

class ViewController < Controller

    def render(*args)
        render_template(*args)
    end

    def render_template(view_name, locals = {})
        vars = {}
        instance_variables.each do |var|
            key = var.to_s.gsub("@", "").to_sym
            vars[key] = instance_variable_get(var)
        end

        slim view_name, locals.merge(vars)
    end

    def dispatch(action, *args)
        build_route(args) # exceptions
        view, locals = self.send(action, *args)
        render(view, locals)
    end

    def self.view(action_name, env, *args)
        -> (env) { self.new(env).dispatch(action_name, args) }
    end

end