def init_router(router)
  router.draw do
    get Regexp.new("^/cats$"), Cats2Controller, :index
    get Regexp.new("^/cats/(?<cat_id>\\d+)$"), CatsController, :show
    get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), StatusesController, :index
  end
end
