require_relative '../../dsl/route_factory.rb'

RouteFactory.define do
    factory :user do |params, db_handle|
        # fetch from database
    end

    factory :user_type do |params, db_handle|
        # parse from params
    end
end