class CatsController < ControllerBase
$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]
  def show
    session["count"] ||= 0
    session["count"] += 1
    @cat = $cats.find do |s|
      s[:id] == Integer(params['cat_id'])
    end
    # debugger
    render :show
  end

end
