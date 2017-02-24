require 'erubis'
class Hello
  # customize the output of our object inside of ERB templates
  def to_s
    'Custom string'
  end
end
template = <<TEMPLATE
Hello this is a template
It has <%= things %>
TEMPLATE

eruby = Erubis::Eruby.new template
puts eruby.src
puts '======'
puts eruby.result things: Hello.new
