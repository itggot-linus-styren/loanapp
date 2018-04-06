require_relative '../../dsl/route_factory.rb'

RouteFactory.define do
    factory :loanable do |params, _|
        # fetch from database
    end

    factory :loanable_type do |params, _|
        # parse from params
    end
end