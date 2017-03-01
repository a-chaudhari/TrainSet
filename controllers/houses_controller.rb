class HousesController < ControllerBase
  protect_from_forgery
  def index
    @houses = House.all
    render :index
  end

  def new
    render :new
  end

  def create
    # debugger
    house = House.new(address: params['house']['address'])
    if house.save
      redirect_to '/houses'
    else
      flash.now[:errors] = house.errors
      render :new
    end
  end

  def edit
    @house = House.find(Integer(params['id']))
    render :edit
  end

  def update
    # debugger
    @house = House.find(Integer(params['id']))
    @house.update_attributes(params['house'])
    if @house.save
      redirect_to '/houses'
    else
      flash.now[:errors] = @house.errors
      render :edit
    end
  end

  def show
    @house = House.find(Integer(params['id']))
    render :show
  end



end
