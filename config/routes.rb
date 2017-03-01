def init_router(router)
  router.draw do
    get Regexp.new("^/cats$"), CatsController, :index
    get Regexp.new("^/cats/(?<cat_id>\\d+)$"), CatsController, :show
    # get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
    get rgen('/cats/new'), CatsController, :new
    post rgen('/cats'), CatsController, :create

    get Regexp.new("^/houses$"), HousesController, :index
    get rgen('/houses/(?<id>\\d+)/edit'), HousesController, :edit
    put rgen('/houses/(?<id>\\d+)'), HousesController, :update
    get rgen('/houses/(?<id>\\d+)'), HousesController, :show
    get Regexp.new("^/houses/new$"), HousesController, :new
    post Regexp.new("^/houses$"), HousesController, :create

    get rgen('/humans'), HumansController, :index
    get rgen('/humans/(?<human_id>\\d+)'), HumansController, :show
    get rgen('/humans/new'), HumansController, :new
    post rgen('/humans'), HumansController, :create

    get Regexp.new("^/$"), RootController, :index

  end
end

def rgen(path)
  Regexp.new("^#{path}$")
end
