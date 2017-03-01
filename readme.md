# TrainSet
TrainSet is a lightweight MVC framework inspired by Ruby on Rails.  Also included is TapeDeck, a lightweight ORM inspired by ActiveRecord.  TrainSet provides `ControllerBase` and `Router`, which provide a base controller class and basic routing capabilities respectively. TapeDeck provides `TapeDeck` which gives access to associations

## TapeDeck
Classes that inherit TapeDeck have access to a number of ORM functions.
* parameters can be passed into the initializer or `update_attributes` as an options hash
```` ruby
sol = OS.new(name: 'Solaris', vendor:'Sun', model:'proprietary',license:'CDDL')
sol.update_attributes(vendor:'Oracle',license:'OTN')
````
* Models can optionally override `valid?` to provide input validation before inserting or updating to DB. The overriden function must return either true or false.  Error messages can also be shoveled into `errors`.
```` ruby
def valid?
    if name.empty?
      errors['name'] = "Name cannot be blank"
      return false
    end
    true
end
````
* The `model.save` method will automatically either INSERT or UPDATE as needed.
* The following relations are provided:
    * belongs_to
    * has_many
    * has_one_through
    * has_many_through

### Example Usage
```` ruby
class OS < TapeDeck
    #every model must finalize!
    self.finalize!

    belongs_to :vendor
    belongs_to :OS_Family,
      foreign_key: :os_family_id
    has_many_through :similar_operating_systems,
      through: :OS_Family,
      source: :operating_systems
end
````
Models are stores in the `$project_dir/models/` folder

## TrainSet
### Key Features
* `render(template name)` : will render the template located in `$project_dir/views/$controller_name/` directory
* `render_content(content, type)`: Will render custom content, such as JSON
````ruby
render_content(data.to_json, "application/json")
````
* `redirect_to(url)`
* `session`: stores key/value pairs in the browser cookie.  
* `flash` and `flash.now`: stores single-session cookies and same-session data respectively.

### Example Usage
````ruby
class OSController < TrainSet

  def new
    @os = OS.new
    render :new
  end

  def create
    @os = OS.new(params['OS'])
    if @os.save
      redirect_to "/os/#{os.id}"
    else
      flash.now[:errors]=@os.errors
      render :new
    end
  end

end
````
Controllers are stored in the `$project_dir/controllers/` folder using snake_case naming.

## Router
TrainSet includes a lightweight router that can handle custom routes.

### Example Usage
````ruby
get Regexp.new("^/os$"), OSController, :index
get Regexp.new('^/os/(?<id>\\d+)/edit$'), OSController, :edit
put Regexp.new('^/os/(?<id>\\d+)$'), OSController, :update
get Regexp.new('^/os/(?<id>\\d+)$'), OSController, :show
get Regexp.new("^/os/new$"), OSController, :new
post Regexp.new("^/os$"), OSController, :create
````
Routes are added to the `router.draw do` block in the `$project_dir/config/routes.rb` file



## Additional Middleware
A static assets middleware is provided.  It will serve out of the `public` folder.  By default it will recognize txt, jpg, png, and zip files.  Additional MIME types can be added by appending to the `MIME_TYPES` constant in `static.rb`

## Operation

1. `bundle install`
1. `ruby ./bin/server.rb`
1. Visit `http://localhost:3000`
