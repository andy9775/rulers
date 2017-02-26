require 'rulers/version'
require 'rulers/array' # make convenience methods/classes available to apps
require 'rulers/hash' # make convenience methods/classes available to apps
require 'rulers/routing'
require 'rulers/util'
require 'rulers/dependencies'
require 'rulers/controller'
require 'rulers/file_model'

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        # ignore requests for favicon
        return [404, { 'Content-Type' => 'text/html' }, []]
      end

      # fetch the controller and action to use from the URL
      # e.g. /quotes/q_quote (quotes controller a_quote action (method))
      klass, action = get_controller_and_action env
      controller = klass.new env

      # send action calls the controllers action for requested route.
      # Internally, the action can either set instance variables and do nothing
      # or it can call render with a specific view path and local variables
      controller.send action

      unless controller.response
        # user did not call render. Render the view associated with the action.
        # only instance variables set. action is the view_name
        controller.render action
      end

      # Rack::Response - contains the response text, status and header info
      status, headers, response = controller.response.to_a
      [status, headers, [response.body].flatten]
    end
  end
end
