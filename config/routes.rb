def init_router(router)
  router.draw do
    #routes go here...
  end
end

def rgen(path)
  Regexp.new("^#{path}$")
end
