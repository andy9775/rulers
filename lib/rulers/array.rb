# Override the default array methods
# this is how rails adds convenience methods to built in classes or adds extra
# helper classes - add all needed code to lib/rulers directory

class Array
  def sum(start = 0)
    inject start, &:+
  end
end
