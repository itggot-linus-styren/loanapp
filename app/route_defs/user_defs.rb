require_relative '../../dsl/route_factory.rb'

RouteFactory.define do
    factory :user do |params, permissions|
        # fetch from database + check perms
    end

    factory :user_type do |params, _|
        # parse from params
    end
end