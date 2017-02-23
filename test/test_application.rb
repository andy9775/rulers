require_relative 'test_helper' # require from this directory not load path

class TestApp < Rulers::Application; end

# includes assertions
# ruby-doc.org/stdlib-1.8.7/libdoc/test/unit/rdoc/Test/Unit/Assertions.html
class RulersAppTest < Test::Unit::TestCase
  # contains http and helper methods and requires that a 'app' method is defined
  # http://www.rubydoc.info/github/brynary/rack-test/Rack/Test/Methods
  include Rack::Test::Methods

  # create a new instance of the app - used by Rack test methods
  def app
    TestApp.new
  end

  def test_request
    get '/'

    assert last_response.ok?
    assert last_response.body['Hello']
  end

  def test_request_headers
    get '/'

    assert last_response.ok?
    assert_equal 'text/html', last_response.headers['Content-Type']
  end
end
