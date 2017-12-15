require 'sinatra/base'

module Sinatra
    module FrameworkHelper

		def partial(page, options={}, &block)
			if block_given?
    			slim page, options.merge!(:layout => false), &block
    		else
				slim page, options.merge!(:layout => false)
    		end
  		end

      end

    helpers FrameworkHelper
end