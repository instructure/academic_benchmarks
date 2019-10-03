require 'academic_benchmarks/lib/inst_vars_to_hash'
require 'academic_benchmarks/lib/remove_obsolete_children'

module AcademicBenchmarks
  module Standards
    class Standard
      include InstVarsToHash
      include RemoveObsoleteChildren

      attr_reader :status, :deepest, :children
      attr_writer :grade
      attr_accessor :guid, :description, :number, :stem, :label, :level,
                    :version, :seq, :adopt_year, :authority, :course,
                    :document, :has_relations, :subject, :subject_doc,
                    :parent, :parent_guid

      alias_method :descr, :description

      def initialize(data)
        data = data["data"] if data["data"]
        @seq = data["seq"]
        @guid = data["guid"]
        @grade = attr_to_val_or_nil(Grade, data, "grade")
        @label = data["label"]
        @level = data["level"]
        @course = attr_to_val_or_nil(Course, data, "course")
        @number = data["number"]
        @status = data["status"]
        @parent = nil
        @subject = attr_to_val_or_nil(Subject, data, "subject")
        @deepest = data["deepest"]
        @version = data["version"]
        @children = []
        @document = attr_to_val_or_nil(Document, data, "document")
        @authority = attr_to_val_or_nil(Authority, data, "authority")
        @adopt_year = data["adopt_year"]
        @description = data["descr"]
        @subject_doc = attr_to_val_or_nil(SubjectDoc, data, "subject_doc")
        @has_relations = attr_to_val_or_nil(HasRelations, data, "has_relations")

        # Parent guid extraction can be a little more complicated
        if data["parent"] && data["parent"].is_a?(String)
          @parent_guid = data["parent"]
        elsif data["parent"] && data["parent"].is_a?(Hash)
          @parent_guid = data["parent"]["guid"]
        end
      end

      alias_method :from_hash, :initialize

      def active?
        status == "Active"
      end

      def obsolete?
        status == "Obsolete"
      end

      def deepest?
        deepest == 'Y'
      end

      def status=(status)
        unless %w[Active Obsolete].include?(status)
          raise ArgumentError.new(
            "Standard status must be either 'Active' or 'Obsolete'"
          )
        end
        @status = status
      end

      def deepest=(deepest)
        unless %w[Y N].include?(deepest)
          raise ArgumentError.new("Standard deepest must be either 'Y' or 'N'")
        end
        @deepest = deepest
      end

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

      def leaf?
        !has_children?
      end

      def grade
        return @grade if @grade

        # check to see if one of our parents has a grade.  Use that if so
        p = parent
        while p
          return p.grade if p.grade
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
