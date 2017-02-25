require_relative 'view_helpers'

module Rulers
  module View
    class View # :nodoc:
      def initialize(controller_name)
        @controller_name = controller_name

        build_helpers
      end

      # set the rulers defined and user defined helpers
      def build_helpers
        Erubis::Eruby.include Rulers::View # include defined view helpers

        helper = /(.*)(Controller)/.match @controller_name
        helper = "#{helper[1]}Helper"
        helper_file = Rulers.to_underscore helper

        # user defined helpers
        require File.join Dir.pwd, 'app', 'helpers', helper_file
        Erubis::Eruby.include Object.const_get helper
      end

      # render an erb template with variables. Return rendered/compiled text
      # rails: github.com/rails/rails/blob/master/actionview/lib/action_view.rb
      # rails: github.com/rails/rails/tree/master/actionview/lib/action_view
      # rails github.com/rails/rails/blob/master/actionview/lib/action_view/template/handlers/erb.rb
      def render_template(view_name, view_path, locals = {})
        filename = File.join('app',
                             'views',
                             view_path,
                             "#{view_name}.html.erb")
        template = File.read filename
        eruby = Erubis::Eruby.new template

        eruby.result locals.merge(rulers_version: VERSION,
                                  controller: @controller_name,
                                  view_path: view_path)
      end
    end
  end
end
