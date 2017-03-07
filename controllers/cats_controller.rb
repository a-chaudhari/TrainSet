class CatsController < ControllerBase

  def show
    @cat = Cat.find(Integer(params['cat_id']))
    render :show
  end

  def index
    @cats= Cat.all
    render :index
  end

  def new
    render :new
  end

  def create
    cat = Cat.new(params['cat'])
    if cat.save
      redirect_to "/cats/#{cat.id}"
    else
      flash.now[:errors] = cat.errors
      render :new
    end
  end

end
