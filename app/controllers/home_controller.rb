require_relative 'controller.rb'

class HomeController < Controller
    def index
        type = @ctx.session[:type]
        if type
            @ctx.redirect "/loans/#{type}/view"
        else
            @ctx.redirect "/loans"
        end
    end
end

class HomeViewController < ViewController
    def index
        :'index', {}
    end
end