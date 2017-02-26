class RouteObject
  def initialize
    @rules = []
  end

  def root(dest, *args)
    get '/', *args.unshift(dest)
  end

  def post(url, *args)
    set_http_method url, :post, *args
  end

  def put(url, *args)
    set_http_method url, :put, *args
  end

  def delete(url, *args)
    set_http_method url, :delete, *args
  end

  def patch(url, *args)
    set_http_method url, :patch, *args
  end

  def get(url, *args)
    set_http_method url, :get, *args
  end

  def resources(resource)
    resource = resource.to_s.end_with?('/') ? resource.to_s[-1] : resource.to_s
    controller = resource.split('/').select { |u| !u.empty? }[0].downcase

    get resource, "#{controller}#index"
    post resource, "#{controller}#create"

    get "#{resource}/new", "#{controller}#new"
    get "#{resource}/:id/edit", "#{controller}#edit"

    get "#{resource}/:id", "#{controller}#show"
    patch "#{resource}/:id", "#{controller}#update"
    put "#{resource}/:id", "#{controller}#update"
    delete "#{resource}/:id", "#{controller}#destroy"
  end

  def resource(resource)
    resource = resource.to_s.end_with?('/') ? resource.to_s[-1] : resource.to_s
    controller = resource.split('/').select { |u| !u.empty? }[0].downcase

    get "#{resource}/new", "#{controller}#new"
    get "#{resource}/:id/edit", "#{controller}#edit"
    get "#{resource}/:id", "#{controller}#show"

    patch "#{resource}/:id", "#{controller}#update"
    put "#{resource}/:id", "#{controller}#update"
    delete "#{resource}/:id", "#{controller}#destroy"

    post resource, "#{controller}#create"
  end

  def set_http_method(url, method, *args)
    if !args[-1].instance_of? Hash
      args.push(method: method)
    else
      args[-1] = args[-1].merge(method: method)
    end
    match url, *args
  end

  # specify the route url and controller to match
  def match(url, *args)
    options = {}
    options = args.pop if args[-1].is_a? Hash
    options[:default] ||= {}

    raise "HTTP method not set for \"#{url}\"" unless options[:method]

    dest = nil
    dest = args.pop unless args.empty?
    raise 'Too many args!' unless args.empty?

    parts = url.split '/'
    parts.select! { |p| !p.empty? }

    # build regular expression string matching section-for-section for passed
    # url. e.g. '/hello/:id' -> '/hello/([a-zA-Z0-9]+)'. Vars is used to attach
    # each regular expression match to a name e.g. '/hello/:id' -> ['id']
    vars = []
    regexp_parts = parts.map do |part|
      if part[0] == ':'
        vars << part[1..-1].to_sym
        '([a-zA-Z0-9]+)'
      elsif part[0] == '*'
        vars << part[1..-1].to_sym
        '(.*)'
      else
        part
      end
    end

    regexp = regexp_parts.join '/'
    @rules.push(regexp: Regexp.new("^/#{regexp}$"),
                vars: vars,
                dest: dest,
                options: options)
  end

  def check_url(url, method, query_params)
    @rules.each do |rule|
      match = rule[:regexp].match url

      next unless match && method.casecmp(rule[:options][:method].to_s.upcase).zero?
      options = rule[:options]
      params = options[:default].dup
      rule[:vars].each_with_index do |var, index|
        params[var] = match.captures[index]
      end
      params = params.merge query_params
      params.symbolize_keys!

      if rule[:dest] # either /:controller/:action
        return get_dest rule[:dest], params
      else # ...or 'controller#action
        controller = params[:controller]
        action = params[:action]
        return get_dest "#{controller}##{action}", params
      end
    end
    nil
  end

  def get_dest(dest, routing_params = {})
    return dest if dest.respond_to? :call
    if dest =~ /^([^#]+)#([^#]+)$/
      name = Regexp.last_match(1).capitalize
      controller = Object.const_get "#{name}Controller"
      return controller.action Regexp.last_match(2), routing_params
    end
    raise "No Destination #{dest.inspect}!"
  end
end

module Rulers
  class Application
    def route(&block)
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&block)
      @route_obj.instance_eval { p @rules}
    end

    # return the controller for the requested url if the routing rules match
    def get_rack_app(env)
      raise 'No Routes!' unless @route_obj

      @route_obj.check_url(
        request_url(env['PATH_INFO']),
        env['REQUEST_METHOD'],
        request_query_params(env['QUERY_STRING'])
      )
    end

    # extract the query parameters from a request
    # i.e. {id: '1'} for /search?id=1
    def request_query_params(query_string)
      query_string
        .split
        .map { |e| e.split('=') }
        .to_h
    end

    # format the request url path
    def request_url(url_string)
      return url_string.gsub(/\/$/, '') if url_string.length > 1
      url_string
    end

    def get_controller_and_action(env)
      _, controller, action, after = env['PATH_INFO'].split('/', 4)
      controller = controller.capitalize
      controller += 'Controller'
      [Object.const_get(controller), # lookup any name starting with capital
       action]
    end
  end
end
