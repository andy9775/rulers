class Test
  def initialize
    @i = { hello: 'world' }
  end

  def hello_world
    puts 'hello world called'
  end
end

a = Test.new
a.instance_eval { puts @i } # execute the block in the context of 'a'

# access instance methods of Test
a.instance_eval do
  hello_world
end
