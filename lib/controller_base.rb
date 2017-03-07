require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  def self.protect_from_forgery
    @@csrf = true
  end

  def initialize(req, res, route_params={})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
  end

  def already_built_response?
    @already_built_response ||= false
  end

  def form_authenticity_token
    @val ||= SecureRandom.urlsafe_base64(16)
    @res.set_cookie("authenticity_token", { :path => '/',  :value => @val} )
    @val
  end

  def check_authenticity_token(token)
    res = @req.cookies["authenticity_token"]
    raise "Invalid authenticity token" if res.nil?
    raise "Invalid authenticity token" unless res==token
    true
  end

  def redirect_to(url)
    if already_built_response?
      raise "double render"
    end
    res.status = 302
    res.location=url
    @already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

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

  def render(template_name)
    controller_name = self.class.to_s.underscore
    path = "views/#{controller_name}/#{template_name.to_s}.html.erb"
    data = File.read(path)
    erb = ERB.new(data).result(binding)
    render_content(erb,'text/html')
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def invoke_action(name)
    res = false
    begin
      res = @@csrf
    rescue NameError
      #do nothing :D
    end

    if res == true && @req.request_method != "GET"
      token = @req.cookies["authenticity_token"]
      check_authenticity_token(token)
    end

    send(name)
    render(name) unless already_built_response?
  end
end
