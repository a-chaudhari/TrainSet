class HumansController < ControllerBase

  def index
    @humans = Human.all
    render :index
  end

  def show
    @human = Human.find(params['human_id'])
    render :show
  end

  def new
    @human = Human.new
    render :new
  end

  def create
    @human = Human.new(params['human'])
    if @human.save
      redirect_to "/humans/#{@human.id}"
    else
      flash.now[:errors] = @human.errors
      render :new
    end
  end


end
