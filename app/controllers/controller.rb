require 'sinatra/base'

class ViewController

    def initialize(ctx)
        @ctx = ctx
        @usermgr = ctx.settings.usermgr
        @loanmgr = ctx.settings.loanmgr
    end

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

    def abort_route(&block)
        yield if block_given?
        redirect redirect_to_back_or_default
    end

    def dispatch(action, *args)
        #create DSL
        view, locals = self.send(action, *args)
        render(view, locals)
    end

    def self.view(action_name, env, *args)
        -> (env) { self.new(env).dispatch(action_name, args) }
    end

end

class Controller
    
    def initialize(ctx)
        @ctx = ctx
        @usermgr = ctx.settings.usermgr
        @loanmgr = ctx.settings.loanmgr
    end

    def abort_route(&block)
        yield if block_given?
        redirect redirect_to_back_or_default
    end

    def dispatch(action, *args)
        #create DSL
        self.send(action, *args)            
    end

    def self.action(action_name, env, *args)
        -> (env) { self.new(env).dispatch(action_name, args) }
    end

end