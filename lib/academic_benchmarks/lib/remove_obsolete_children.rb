module RemoveObsoleteChildren
  def remove_obsolete_children
    @children.delete_if do |child|
      unless child.obsolete?
        child.remove_obsolete_children
      end
      child.obsolete?
    end
  end
end
