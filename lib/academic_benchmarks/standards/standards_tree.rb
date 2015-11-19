module AcademicBenchmarks
  module Standards
    class StandardsTree
      attr_reader :root_standard

      # The item hash can optionally be built to permit the speedy
      # addition of standards to the tree. since the tree is unordered,
      # adding to it can be expensive without this

      def initialize(root_standard, build_item_hash: true)
        @root_standard = root_standard
        if build_item_hash
          @item_hash = {}
          go_ahead_and_build_item_hash
        end
      end

      def add_standard(standard)
        if standard.is_a?(Standard)
          parent = @item_hash ? @item_hash[standard.parent_guid] : find_parent(standard)
          unless parent
            raise StandardError.new(
              "Parent of standard not found in tree. Parent guid is " \
              "'#{standard.parent_guid}' and child guid is '#{standard.guid}'"
            )
          end
          parent.add_child(standard)
          standard.parent = parent
        elsif standard.is_a?(Hash)
          add_standard(Standard.new(standard))
        else
          raise ArgumentError.new(
            "standard must be an 'AcademicBenchmarks::Standards::Standard' " \
            "or a 'Hash' but was a #{standard.class.to_s}"
          )
        end
      end

      private

      def go_ahead_and_build_item_hash
        @item_hash[@root_standard.guid] = @root_standard
        add_children_to_item_hash(@root_standard)
      end

      def add_children_to_item_hash(parent)
        parent.children.each do |child|
          @item_hash[child.guid] = child
          add_children_to_item_hash(child) if child.has_children?
        end
      end

      def find_parent(standard)
        return @root_standard if @root_standard.guid == standard.parent_guid
        check_children_for_parent(standard.parent_guid, @root_standard)
      end

      # does a depth-first search
      def check_children_for_parent(parent_guid, standard)
        standard.children.each do |child|
          return child if child.guid == parent_guid
          check_children_for_parent(parent_guid, child) if child.has_children?
        end
      end
    end
  end
end
