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
      rack_app = get_rack_app env
      rack_app.call env
    end
  end
end
