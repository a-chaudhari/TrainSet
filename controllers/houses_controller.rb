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


end
