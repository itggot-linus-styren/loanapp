class LoanApp < Sinatra::Base

    #enable :sessions
    use Rack::Session::Cookie,  :key => 'rack.session',
    #                            :domain => '127.0.0.1',
    #                            :path => '/',
                                :expire_after => 2592000, # In seconds
                                :secret => 'qgPvYdBwZDcb9UKWW39O'
    set :database_file, 'config/database.yml'
    register Sinatra::Flash
    register Sinatra::ActiveRecordExtension
    helpers Sinatra::LoanHelper, Sinatra::ReturnHelper, Sinatra::CreateHelper,
            Sinatra::UserHelper, Sinatra::InvitationHelper, Sinatra::FrameworkHelper
       
    before do
        if !['loginapp', 'invite', nil].include?(request.path_info.split('/')[1]) && !session[:permitted]
            halt 403, slim(:'forbidden', :layout => false)
        end
    end

    #before do
    #    response.set_cookie 'user_id',
    #        {:value=> 1, :max_age => "2592000"}
    #end

    not_found do
        status 404
        slim :'oops', :layout => false
    end

    get '/' do
        index_route
    end

    get '/invite' do
        invite_route(settings.usermgr)
    end

    get '/invite/:token' do
        claim_invite_route(settings.usermgr, params)
    end

    get '/invited/:token' do
        invited_route(params)
    end

    # temporary
    #get '/register' do
    #    session[:dev] = true
    #    slim :'user/register'
    #end

    get '/logout' do
        logout_route
    end

    get '/loans' do
        loans_route(settings.loanmgr)
    end

    get '/loans/:type' do
        loans_by_type_route(settings.loanmgr, params)
    end

    get '/loans/:type/:responsible' do
        loans_by_responsible_route(settings.loanmgr, params)
    end

    get '/view/:type' do
        view_route(settings.loanmgr, settings.usermgr, params)
    end

    get '/add/:type' do
        add_route(settings.loanmgr, settings.usermgr, params)
    end

    get '/delete/:type/:id' do
        delete_route(settings.loanmgr, settings.usermgr, params)
    end

    get '/loan/:type/:id' do
        loan_route(settings.loanmgr, params)
    end

    get '/return/:type/:id' do
        return_route(settings.loanmgr, params)
    end

    get '/login/:usertype' do
        login_route(settings.usermgr, params)        
    end

    get '/profile' do
        profile_route(settings.usermgr)
    end

    get '/change' do
        change_route(settings.usermgr)
    end

    post '/loginapp' do
        loginapp_route(params)
    end

    post '/authentication' do
        authentication_route(settings.usermgr, params)
    end

    post '/postchange' do
        postchange_route(settings.usermgr, params)
    end

    post '/postregister' do
        postregister_route(params)
    end

    post '/postinvite' do
        postinvite_route(settings.usermgr, params)
    end

    post '/makeloan' do
        makeloan_route(settings.loanmgr, params)        
    end

    post '/postcreate' do
        postcreate_route(settings.loanmgr, params)        
    end

    post '/postreturn' do
        postreturn_route(settings.loanmgr, params)
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