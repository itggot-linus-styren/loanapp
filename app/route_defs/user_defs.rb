require_relative '../../dsl/route_factory.rb'

RouteFactory.define do
    factory :user do |params, permissions|
        user_id = ctx.session[:user_id]
        raise RouteDefError, "You are not logged in." unless user_id

        user = User.find(user_id)

        permissions&.each do |perm|
            raise RouteDefError, "You do not have the \"#{perm}\" permission." unless usermgr.has_permission?(user, perm.to_sym)
        end

        factory_set({:user => user})
    end

    factory :user_type do |params, _|
        type = params[:usertype]
        if type    
            raise RouteDefError, "The usertype \"#{type}\" is unknown." unless usermgr.has_association(type)
            
            factory_set({:user_type => type})
        end
    end
end