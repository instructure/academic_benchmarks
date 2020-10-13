module AttrToVals
  def attr_to_vals(klass, arr)
    return [] if arr.nil?

    arr.map {|v| klass.from_hash(v)}
  end
end
