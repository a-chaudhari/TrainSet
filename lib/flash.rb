require 'json'

class Flash

  attr_reader :now

  def initialize(req)
    if req.cookies["_rails_lite_app_flash"].nil?
      @flash_old={}
    else
      @flash_old = JSON.parse(req.cookies["_rails_lite_app_flash"])
    end
    @flash = {}
    @now={}
  end

  def [](key)
    things = [key.to_s, key.to_sym]
    things.each do |thing|
      return @now[thing] unless @now[thing].nil?
      return @flash_old[thing] unless @flash_old[thing].nil?
      return @flash[thing] unless @flash[thing].nil?
    end
    nil
  end


  #flash.now[:errors] =["error"]
  # render :new
  #flash[:errors] =>

  def []= (key,val)
    @flash[key]=val
  end
  #
  # def now[]= (key,val)
  #   @flash[key]=val
  #   @now << key
  # end


  def store_flash(res)
    # phase_one_hash = {}
    # @flash.each do |key,val|
    #   phase_one_hash[key]=val unless @now.include?(key)
    # end

    phase_two_hash = { :path => :/, :value => @flash.to_json  }
    res.set_cookie("_rails_lite_app_flash", phase_two_hash)
  end

end
