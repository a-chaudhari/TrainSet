require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  def self.protect_from_forgery
    #get params
    # debugger
    @@csrf = true


  end


  # Setup the controller
  def initialize(req, res, route_params={})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  def form_authenticity_token
    @val ||= SecureRandom.urlsafe_base64(16)
    @res.set_cookie("authenticity_token", { :path => '/',  :value => @val} )
    # @req.set_
    @val

  end

  def check_authenticity_token(token)
    res = @req.cookies["authenticity_token"]
    raise "Invalid authenticity token" if res.nil?
    raise "Invalid authenticity token" unless res==token
    true
  end

  # Set the response status code and header
  def redirect_to(url)
    if already_built_response?
      raise "double render"
    end
    # debugger
    res.status = 302
    res.location=url
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise("double render")
    end
    res['Content-Type'] = content_type
    res.write(content)
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    path = "views/#{controller_name}/#{template_name.to_s}.html.erb"
    data = File.read(path)
    erb = ERB.new(data).result(binding)
    render_content(erb,'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    res = false
    begin
      res = @@csrf
    rescue NameError
      #do nothing :D
    end


    # debugger
    #check csrf unless it's a get
    if res == true && @req.request_method != "GET"
      # debugger
      token = @req.cookies["authenticity_token"]
      check_authenticity_token(token)
    end

    send(name)
    render(name) unless already_built_response?
  end
end
