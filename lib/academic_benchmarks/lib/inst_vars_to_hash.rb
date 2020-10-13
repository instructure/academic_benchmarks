#
# This module will allow you to properly to_s, to_h, and to_json
# on classes in which it is included.
#
# It is not intended to be general purpose, but rather should
# be used only with standards and standards-related data
# structures, which themselves are mirrors of the JSON
# definitions used by Academic Benchmarks
#

module InstVarsToHash
  def to_s(omit_parent: true, omit_empty_children: true)
    to_h(
      omit_parent: omit_parent,
      omit_empty_children: omit_empty_children
    ).to_s
  end

  def to_h(omit_parent: true, omit_empty_children: true)
    retval = {}
    instance_variables.each do |iv|
      # Don't hashify these attributes, otherwise it can lead to infinite recursion
      next if %w[@authority @document @publication @section].include? iv.to_s
      if !(skip_parent?(omit_parent, iv) || skip_children?(omit_empty_children, iv))
        retval[iv.to_s.delete('@').to_sym] = elem_to_h(instance_variable_get(iv))
      end
    end
    retval
  end

  def to_json(omit_parent: true, omit_empty_children: true)
    to_h(
      omit_parent: omit_parent,
      omit_empty_children: omit_empty_children
    ).to_json
  end

  private

  def expandable_classes
    [ Hash, InstVarsToHash ]
  end

  def expandable_to_hash(klass)
    expandable_classes.any?{ |k| klass == k || klass < k }
  end

  def elem_to_h(elem)
    if elem.class == Array
      elem.map { |el| elem_to_h(el) }
    elsif expandable_to_hash(elem.class)
      elem.to_h
    else
      elem
    end
  end

  def skip_parent?(omit_parent, iv)
    omit_parent && (iv =~ /^@?parent$/i)
  end

  def skip_children?(omit_empty_children, iv)
    omit_empty_children && (iv =~ /^@?children$/i) && instance_variable_get(iv).empty?
  end
end
