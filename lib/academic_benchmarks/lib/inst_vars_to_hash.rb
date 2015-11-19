
module InstVarsToHash
  def to_s
    to_h.to_s
  end

  def to_h
    retval = {}
    instance_variables.each do |iv|
      retval[iv.to_s.gsub('@', '').to_sym] = instance_variable_get(iv)
    end
    retval
  end
end
