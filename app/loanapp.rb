class LoanApp < Sinatra::Base

    #enable :sessions
    use Rack::Session::Cookie,  :key => 'rack.session',
                                :expire_after => 2592000, # In seconds
                                :secret => File.read('config/cookie').strip
    set :database_file, 'config/database.yml'
    set :public_folder, 'public'
    register Sinatra::Flash
    register Sinatra::ActiveRecordExtension

    attr_accessor :locals
    
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
            HomeController.action(:index, self).call
        else
            HomeViewController.view(:index, self).call
        end
    end

    get '/invites/new' do
        InvitesViewController.view(:new, self).call
    end

    get '/invites/:token' do
        InvitesViewController.view(:index, self, params).call
    end

    get '/invites/:token/claim' do
        InvitesViewController.view(:claim, self, params).call
    end
    
    get '/loans' do
        LoansViewController.view(:index, self, params).call
    end

    get '/loans/:type/view' do
        LoansViewController.view(:view, self, params).call
    end

    get '/loans/:type/new' do
        LoansViewController.view(:new, self, params).call
    end

    get '/loans/:type/:id/edit' do
        LoansViewController.view(:edit, self, params).call
    end    

    get '/loans/:type/:id/loan' do
        LoansViewController.view(:loan, self, params).call
    end

    get '/loans/:type/:id/return' do
        LoansViewController.view(:return, self, params).call
    end

    get '/user/profile' do
        UserViewController.view(:profile, self).call
    end

    get '/user/logout' do # probably should be a post....
        UserController.action(:logout, self).call
    end

    get '/user/:usertype/login' do
        UserViewController.view(:login, self, params).call
    end

    get '/loginapp/change' do
        LoginAppViewController.view(:change, self).call
    end

    post '/loginapp' do
        LoginAppController.action(:index, self, params).call
    end

    post '/loginapp/change' do
        LoginAppController.action(:change, self, params).call
    end

    post '/user/register' do
        UserController.action(:register, self, params).call
    end

    post '/user/:usertype/login' do        
        UserController.action(:login, self, params).call
    end

    post '/invites/new' do
        InvitesController.action(:new, self, params).call
    end    

    post '/loans/:type/:id/loan' do    
        LoansController.action(:loan, self, params).call
    end

    post '/loans/:type/new' do
        LoansController.action(:new, self, params).call
    end

    post '/loans/:type/:id/edit' do
        LoansController.action(:edit, self, params).call
    end

    post '/loans/:type/:id/delete' do
        LoansController.action(:delete, self, params).call
    end

    post '/loans/:type/:id/return' do
        LoansController.action(:return, self, params).call
    end
    
    def redirect_to_back_or_default(default = '/')
        # "and" operator has lower precedence than "!=" operator
        if request.env["HTTP_REFERER"].present? and request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
            redirect back
        else
            redirect default
        end
    end

    def partial(page, options={}, &block)        
        if block_given?
            slim page, options.merge!(:layout => false), @locals, &block
        else
            slim page, options.merge!(:layout => false), @locals
        end
    end

    def validate_fields(form)
        form.each do |field, value|
            if value.blank?
                flash[:error] = "You must fill in the field \"#{field}\"."
                flash[:field] = field
                return true
            end
        end
        return false
    end
    
    after do
        # Close the connection after the request is done so that we don't
        # deplete the ActiveRecord connection pool.
        ActiveRecord::Base.connection.close
        @locals = nil
    end

end