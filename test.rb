class Test
  class << self
    def method_missing(m, *args, &block)
      p args
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s == 'find_by_word'
    end
  end
end

Test.find_by_word 1, 2
Test.method :find_by_word
