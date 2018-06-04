require 'sinatra/base'

class Controller
    
    def initialize(ctx)
        @ctx = ctx
        @usermgr = ctx.settings.usermgr
        @loanmgr = ctx.settings.loanmgr        
    end

    def build_route(route_name, args)
        defs, perms = RouteParser.instance.fetch_defs(route_name.to_s, self.class)
        puts defs.inspect
        defs.each do |route_def|
            RouteFactory.build(self, route_def, args + [perms])
        end
    end

    def abort_route(&block)
        raise ControllerError, yield if block_given?
    end

    def dispatch(action, args)
        begin
            build_route(action, args)
            self.send(action, *args)
        rescue RouteDefError, ControllerError => ex
            @ctx.flash[:error] = ex.message
            @ctx.redirect_to_back_or_default
        end
    end

    def self.action(action_name, env, *args)
        -> () { self.new(env).dispatch(action_name, args) }
    end

end

class ViewController < Controller

    def render(args)
        if args.length < 3 # show layout
            args << true
        end
        render_template(*args)
    end

    def render_template(view_name, locals = {}, layout)
        vars = {}
        instance_variables.each do |var|
            key = var.to_s.gsub("@", "").to_sym
            vars[key] = instance_variable_get(var)
        end

        @ctx.locals = vars
        @ctx.slim(view_name, {:layout => layout}, locals.merge(vars))
    end

    def dispatch(action, args)
        begin
            build_route(action, args)       
            render(self.send(action, *args))
        rescue RouteDefError, ControllerError => ex
            @ctx.flash[:error] = ex.message
            @ctx.redirect_to_back_or_default
        end
    end

    def self.view(action_name, env, *args)
        -> () { self.new(env).dispatch(action_name, args) }
    end

end

class ControllerError < StandardError
    
    attr_accessor :message
    
    def initialize(err_msg)
        @message = err_msg
    end
end