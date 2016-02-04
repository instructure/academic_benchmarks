module AcademicBenchmarks
  module Standards
    class StandardsForest
      attr_reader :trees, :data_hash, :orphans

      # The guid to standard hash can optionally be saved to permit speedily
      # adding standards to the tree (since the tree is unordered,
      # this would otherwise be an expensive operation).
      #
      # The initial data hash can also be optionally saved to
      # permit testing and internal consistency checks

      def initialize(
        data_hash,
        save_guid_to_standard_hash: true,
        save_initial_data_hash: false,
        include_obsoletes: true
      )
        @data_hash = data_hash.dup.freeze if save_initial_data_hash
        @guid_to_standard = {} # a hash of guids to standards
        @trees = []
        @orphans = []
        process_items(data_hash)

        @trees.delete_if(&:obsolete?) unless include_obsoletes

        # upgrade the hash data to a StandardsTree object
        @trees.map! do |item|
          StandardsTree.new(
            item,
            build_item_hash: save_guid_to_standard_hash,
            include_obsoletes: include_obsoletes
          )
        end

        # We will still have the guid-to-standards saved at the Tree level,
        # so we can safely remove this variable and let the GC free the memory
        remove_instance_variable('@guid_to_standard')
      end

      def consolidate_under_root(root)
        trees.each do |tree|
          tree.root.parent = root
          tree.root.parent_guid = root.guid
          root.children.push(tree.root)
        end
        StandardsTree.new(root).tap{ |st| st.add_orphans(@orphans) }
      end

      def add_standard(standard)
        if standard.is_a?(Standard)
          raise StandardError.new(
            "adding standards is not currently implemented"
          )
        elsif standard.is_a?(Hash)
          add_standard(Standard.new(standard))
        else
          raise ArgumentError.new(
            "standard must be an 'AcademicBenchmarks::Standards::Standard' " \
            "or a 'Hash' but was a #{standard.class}"
          )
        end
      end

      def single_tree?
        @trees.count == 1
      end

      def empty?
        @trees.empty?
      end

      def has_orphans?
        @orphans.count > 0
      end

      def to_s
        trees.map(&:to_s)
      end

      def to_h
        trees.map(&:to_h)
      end

      def to_json
        trees.map(&:to_json)
      end

      private

      def to_standard(item)
        return item if item.is_a?(Standard)
        Standard.new(item)
      end

      def process_items(data_hash)
        build_guid_to_standard_hash(data_hash)
        link_parent_and_children
      end

      def build_guid_to_standard_hash(data_hash)
        data_hash.each do |item|
          item = to_standard(item)
          @guid_to_standard[item.guid] = item
        end
      end

      def link_parent_and_children
        @guid_to_standard.values.each do |child|
          if child.parent_guid
            parent_in_hash?(child.parent_guid) ? set_parent_and_child(child) : @orphans.push(child)
          else
            @trees.push(child)
          end
        end
      end

      def set_parent_and_child(child)
        parent = @guid_to_standard[child.parent_guid]
        parent.add_child(child)
        child.parent = parent
      end

      def parent_in_hash?(guid)
        @guid_to_standard.key?(guid)
      end
    end
  end
end
