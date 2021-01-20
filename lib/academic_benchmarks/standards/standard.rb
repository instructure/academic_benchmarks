require 'academic_benchmarks/lib/attr_to_vals'
require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Standard
      include AttrToVals
      include InstVarsToHash

      attr_reader :status, :children
      attr_writer :education_levels
      attr_accessor :guid,
                    :statement,
                    :number, :stem, :label, :level,
                    :seq,
                    :section,
                    :document, :disciplines,
                    :utilizations,
                    :parent, :parent_guid

      # Before standards are rebranched in Authority#rebranch_children
      # or Document#rebranch_children, they have the following structure.
      #
      # Standard
      # |-> Document
      # |   |-> Publication
      # |       |-> Authority
      # |-> Section
      #
      def initialize(data)
        attributes = data["attributes"]
        @guid = attributes["guid"]
        @education_levels = attr_to_val_or_nil(EducationLevels, attributes, "education_levels")
        @label = attributes["label"]
        @level = attributes["level"]
        @section = attr_to_val_or_nil(Section, attributes, "section")
        @number = attr_to_val_or_nil(Number, attributes, "number")
        @status = attributes["status"]
        @disciplines = attr_to_val_or_nil(Disciplines, attributes, "disciplines")
        @children = []
        @document = attr_to_val_or_nil(Document, attributes, "document")
        @statement = attr_to_val_or_nil(Statement, attributes, "statement")
        @utilizations = attr_to_vals(Utilizations, attributes["utilizations"])
        @parent_guid = data.dig("relationships", "parent", "data", "id")
      end

      alias_method :from_hash, :initialize

      def add_child(child)
        raise StandardError.new("Tried to add self as a child") if self == child

        unless child.is_a?(Standard)
          raise ArgumentError.new("Tried to set child that isn't a Standard")
        end
        child.parent = self
        @children.push(child)
      end

      def remove_child(child)
        child.parent = nil
        @children.delete(child)
      end

      def has_children?
        @children.count > 0
      end

      def education_levels
        return @education_levels if @education_levels

        # check to see if one of our parents has education levels.  Use that if so
        p = parent
        while p
          return p.education_levels if p.education_levels
          p = p.parent
        end
        nil
      end

      private

      def attr_to_val_or_nil(klass, hash, attr)
        return nil unless hash.key?(attr)
        klass.from_hash(hash[attr])
      end
    end
  end
end
