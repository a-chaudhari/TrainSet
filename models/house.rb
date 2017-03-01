class House < TapeDeck
  self.finalize!

  has_many :humans

  has_many_through :cats, :humans, :cats


  def valid?
    unless address.length > 0
      errors['address']='address cannot be blank'
      return false
    end

    true
  end


end
