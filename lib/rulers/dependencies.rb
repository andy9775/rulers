# rails code:
# github.com/rails/rails/blob/master/activesupport/lib/active_support/dependencies.rb
class Object
  class << self
    # handle missing require calls by converting class name to file name and
    # requiring. This prevents the use of many require statements for our
    # controllers
    def const_missing(c)
      # prevent an infinitely recursive require call for a missing class
      return nil if @calling_const_missing
      @calling_const_missing = true

      # convert class to underscore/lowercase
      require Rulers.to_underscore c.to_s
      # ...and require it automatically
      klass = Object.const_get c

      @calling_const_missing = false

      klass
    end
  end
end
