class Hash
  def order
    new_hash = {}

    Hash[sort].each_value do |value|
      new_hash.merge!(value)
    end

    new_hash
  end
end

