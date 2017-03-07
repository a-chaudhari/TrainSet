require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    if req.cookies["_rails_lite_app"].nil?
      @cookies = {}
      return
    end
    @cookies = JSON.parse(req.cookies["_rails_lite_app"])
  end

  def [](key)
    @cookies[key]
  end

  def []=(key, val)
    @cookies[key]=val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    hash = {:path => "/", :value=> @cookies.to_json}
    res.set_cookie("_rails_lite_app",hash)
  end
end
