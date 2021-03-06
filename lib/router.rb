class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    path_test = @pattern =~ req.path
    method_used = req.request_method.downcase.to_sym
    if(!req.params['_method'].nil?)
      method_used = req.params['_method'].downcase.to_sym
    end
    method_test = method_used == @http_method
    return true if path_test!= nil && method_test
    false
  end

  def run(req, res)
    match_data = Regexp.new(@pattern).match(req.path)
    hash = {}
    match_data.names.each do |name|
      hash[name]=match_data[name]
    end
    @controller_class.new(req, res, hash).invoke_action(@action_name)


  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) { |ptn, cc, an| add_route(ptn, http_method, cc, an) }
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    nil
  end

  def run(req, res)
    route = match(req)
    if route.nil?
      res.status = 404
    else
      route.run(req,res)
    end
  end
end
