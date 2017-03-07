class Static
  attr_reader :req

  MIME_TYPES = {
    "txt" => "text/plain",
    "jpg" => "image/jpeg",
    "png" => "image/png",
    "zip" => "application/zip"
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    @req = Rack::Request.new(env)
    # @res = Rack::Response.new(env)

    if @req.path.match(/^\/public/)
      handle_static
    else
      @app.call(env)
    end
  end

  private
  def handle_static
    path = "." + req.path
    extension = path.match("^.*\.(...)")[1]
    mtype = MIME_TYPES[extension]

    p "serving: " + path + " as: " +mtype

    if File.file?(path)
      ['200', {'Content-type' => mtype }, [File.read(path)]]
    else
      ['404', {'Content-type' => 'text/html'} ,["404 Can't find it"]]
    end
  end
end
