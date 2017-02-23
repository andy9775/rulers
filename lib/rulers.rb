require 'rulers/version'
require 'rulers/array' # make convenience methods/classes available to apps

module Rulers
  class Application
    def call(_env)
      `echo debug > debug.txt` # gets called per request.
      [200, { 'Content-Type' => 'text/html' }, ['Hello from rulers']]
    end
  end
end
