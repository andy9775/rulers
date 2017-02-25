require 'erubis'
require 'rack/request'
require_relative 'version'
require_relative 'file_model'
require_relative 'view'

module Rulers
  class Controller
    include Rulers::Model

    attr_reader :env
    attr_reader :response

    def initialize(env)
      @env = env
    end

    def request
      @request ||= Rack::Request.new @env
    end

    def params
      request.params
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

    # render a view. Arguments include the view name and local variables to
    # render in erb
    def render(*args)
      hashes = args.select { |a| a.class == Hash }.flatten.first || {}

      view_name = args[0]
      unless view_name.class == String || view_name.class == Symbol
        raise "Incorrect view path #{view_name}. Must be a string or a symbol"
      end

      view = View::View.new self.class.to_s
      locals = hashes[:locals] || {}
      locals = locals.merge(instance_vars).merge(env: @env)

      set_response(
        view.render_template(view_name, view_path, locals),
        hashes[:status] || 200,
        hashes[:headers] || { 'Content-Type' => 'text/html' }
      )
    end

    private

    def set_response(text,
                     status = 200,
                     headers = { 'Content-Type' => 'text/html' })
      raise 'Already responded' if @response
      response = [text].flatten
      @response = Rack::Response.new response, status, headers
    end

    # determine the name of the controller and convert it to underscore notation
    # in order to get the directory of the view
    def view_path
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, '')
      Rulers.to_underscore klass
    end
  end
end
