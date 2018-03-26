class LoanApp < Sinatra::Base

    use Rack::Session::Cookie,  :key => 'rack.session',
                                :expire_after => 2592000, # In seconds
                                :secret => File.read('config/cookie').strip
    set :database_file, 'config/database.yml'
    register Sinatra::Flash
    register Sinatra::ActiveRecordExtension

    before do
        # fetch defs from routes.yml

        # RouteFactory.build(HomeController, :)

        # Consider adding def logic to controller super class
    end
       
    before do
        if !['loginapp', 'invite', nil].include?(request.path_info.split('/')[1]) && !session[:permitted]
            halt 403, slim(:'forbidden', :layout => false)
        end
    end

    not_found do
        status 404
        slim :'oops', :layout => false
    end

    get '/' do
        if session[:permitted]
            HomeController.action(:index, self)
        else
            HomeViewController.view(:index, self)
        end        
    end

    get '/invites/:token' do
        InvitesViewController.view(:index, self, params)
    end

    get '/invites/new' do
        InvitesViewController.view(:new, self)
    end

    get '/invites/:token/claim' do
        InvitesViewController.view(:claim, self, params)
    end
    
    get '/loans' do
        LoansViewController.view(:index, self, params)
    end

    get '/loans/:type/view' do
        LoansViewController.view(:view, self, params)
    end

    get '/loans/:type/new' do
        LoansViewController.view(:new, self, params)
    end

    get '/loans/:type/:id/edit' do
        LoansViewController.view(:edit, self, params)
    end    

    get '/loans/:type/:id/loan' do
        LoansViewController.view(:loan, self, params)
    end

    get '/loans/:type/:id/return' do
        LoansViewController.view(:return, self, params)
    end

    get '/user/:usertype/login' do
        UserViewController.view(:login, self, params)
    end

    get '/user/profile' do
        UserViewController.view(:profile, self)
    end

    get '/loginapp/change' do
        LoginAppViewController.view(:change, self)
    end

    post '/loginapp' do
        LoginAppController.action(:index, self, params)
    end

    patch '/loginapp/change' do
        LoginAppController.action(:change, self, params)
    end

    post '/user/:usertype/login' do        
        UserController.action(:login, self, params)
    end    

    post '/user/register' do
        UserController.action(:register, self, params)
    end

    patch '/user/logout' do
        UserController.action(:logout, self)
    end

    post '/invites/new' do
        InvitesController.action(:new, self, params)
    end    

    post '/loans/:type/:id/loan' do    
        LoansController.action(:loan, self, params)
    end

    post '/loans/:type/new' do
        LoansController.action(:new, self, params)  
    end

    patch '/loans/:type/:id/edit' do
        LoansController.action(:edit, self, params)
    end

    patch '/loans/:type/:id/delete' do
        LoansController.action(:delete, self, params)
    end

    patch '/loans/:type/:id/return' do
        LoansController.action(:return, self, params)
    end
    
    def redirect_to_back_or_default(default = '/')
        # "and" operator has lower precedence than "!=" operator
        if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
            redirect back
        else
            redirect default
        end
    end

    
    after do
        # Close the connection after the request is done so that we don't
        # deplete the ActiveRecord connection pool.
        ActiveRecord::Base.connection.close
    end

end