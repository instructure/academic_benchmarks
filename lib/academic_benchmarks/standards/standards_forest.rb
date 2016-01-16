module AcademicBenchmarks
  module Standards
    class StandardsForest
      attr_reader :trees, :data_hash

      # The guid to standard hash can optionally be saved to permit speedily
      # adding standards to the tree (since the tree is unordered,
      # this would otherwise be an expensive operation).
      #
      # The initial data hash can also be optionally saved to
      # permit testing and internal consistency checks

      def initialize(
        data_hash,
        save_guid_to_standard_hash: true,
        save_initial_data_hash: false
      )
        @data_hash = data_hash.dup.freeze if save_initial_data_hash
        @guid_to_standard = {} # a hash of guids to standards
        @trees = []
        process_items(data_hash)

        # upgrade the hash data to a StandardsTree object
        @trees.map! do |item|
          StandardsTree.new(item, build_item_hash: save_guid_to_standard_hash)
        end

        unless save_guid_to_standard_hash
          remove_instance_variable('@guid_to_standard')
        end
      end

      def consolidate_under_root(root)
        trees.each do |tree|
          tree.root.parent = root
          tree.root.parent_guid = root.guid
          root.children.push(tree.root)
        end
        StandardsTree.new(root)
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
            present_in_hash_or_raise(child.parent_guid)
            parent = @guid_to_standard[child.parent_guid]
            parent.add_child(child)
            child.parent = parent
          else
            @trees.push(child)
          end
        end
      end

      def present_in_hash_or_raise(guid)
        unless @guid_to_standard.key?(guid)
          raise StandardError.new(
            "item missing from guid_to_standard hash"
          )
        end
      end
    end
  end
end
