class Cat < TapeDeck
  #connects the table in the DB to the model.
  #currently has to be an existing DB.
  self.finalize!

  belongs_to :human,
    foreign_key: :owner_id


  def valid?
    unless name.length > 0
      errors[:name]="name cannot be blank"
      return false
    end
    true
  end


end
