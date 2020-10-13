require 'active_support/core_ext/module'

module AcademicBenchmarks
  module Standards
    class StandardsTree
      attr_reader :root, :orphans
      delegate :children, :to_s, :to_h, :to_json, to: :root

      def initialize(root)
        @orphans = []
        @root = root
        root.rebranch_children if root.is_a?(Authority) || root.is_a?(Publication)
      end

      def add_orphan(orphan)
        add_orphans([orphan])
      end

      def add_orphans(orphans)
        @orphans.concat(orphans)
      end

      def has_orphans?
        @orphans.present?
      end
    end
  end
end
