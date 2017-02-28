class Human < TapeDeck
  self.finalize!

  has_many :cats,
    foreign_key: :owner_id

  belongs_to :house

  def valid?
    result = true

    unless fname.length > 0
      result=false
      errors['fname']="First Name cannot be blank"
    end

    unless lname.length > 0
      result=false
      errors['lname']="Last Name cannot be blank"
    end

    result
  end

end
