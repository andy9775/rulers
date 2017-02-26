class Hash
  def stringify_keys
    keys.each do |key|
      val = self[key]
      delete key
      self[key.to_s] = val
    end
  end
end
