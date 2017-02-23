require 'rulers/version'
require 'rulers/array' # make convenience methods/classes available to apps
require 'rulers/routing'
require 'rulers/util'
require 'rulers/dependencies'

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
      text = controller.send action

      [200, { 'Content-Type' => 'text/html' }, [text]]
    end
  end

  class Controller
    attr_reader :env

    def initialize(env)
      @env = env
    end
  end
end
