class House < TapeDeck
  self.finalize!


  def valid?
    unless address.length > 0
      errors['address']='address cannot be blank'
      return false
    end

    true
  end


end
