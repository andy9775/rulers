module Rulers
  class << self
    # convert a class name e.g. TestController to its file path e.g.
    # test_controller
    def to_underscore(string)
      string.gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
    end
  end
end
