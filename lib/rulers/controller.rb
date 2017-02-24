require 'erubis'
require_relative 'version'
module Rulers
  class Controller
    attr_reader :env

    def initialize(env)
      @env = env
    end

    # render an erb template with variables
    # rails: github.com/rails/rails/blob/master/actionview/lib/action_view.rb
    # rails: github.com/rails/rails/tree/master/actionview/lib/action_view
    # rails github.com/rails/rails/blob/master/actionview/lib/action_view/template/handlers/erb.rb
    def render(view_name, locals = {})
      filename = File.join('app',
                           'views',
                           view_path,
                           "#{view_name}.html.erb")
      template = File.read filename
      eruby = Erubis::Eruby.new template

      eruby.result locals.merge(env: env,
                                rulers_version: VERSION,
                                controller: self.class.to_s,
                                view_path: view_path)
        .merge(instance_vars)
    end

    private

    # determine the name of the controller and convert it to underscore notation
    # in order to get the directory of the view
    def view_path
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, '')
      Rulers.to_underscore klass
    end

    # specify the instance variables as set by the user
    def instance_vars
      instance_variables
        .select { |var| var != :@env }
        .map { |var| { var => instance_variable_get(var) } }
        .each_with_object({}) do |obj, memo|
        obj.keys.length.times do |n|
          memo[obj.keys[n]] = obj.values[n]
        end
        memo
      end
    end
  end
end
