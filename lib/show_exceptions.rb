require 'erb'
require 'byebug'


class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)

    begin
      app.call(env)
    rescue Exception => e
      render_exception(e)
    end


  end

  private

  def render_exception(e)
    # debugger
    data = File.read('lib/templates/rescue.html.erb')
    erb = ERB.new(data).result(binding)
    #dump html output to file for testing purposes
    # File.open('test.html', 'w'){ |file| file.write(erb)}
    ['500', {'Content-type' => 'text/html'}, erb]
  end

end
