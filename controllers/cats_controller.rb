class CatsController < ControllerBase

  def show
    # session["count"] ||= 0
    # session["count"] += 1
    @cat = Cat.find(Integer(params['cat_id']))
    # debugger
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
