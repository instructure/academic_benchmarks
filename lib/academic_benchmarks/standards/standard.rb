require_relative '../lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Standard
      include InstVarsToHash

      attr_reader :status, :deepest, :children
      attr_accessor :guid, :description, :number, :stem, :label, :level,
                    :version, :seq, :adopt_year, :authority, :course,
                    :document, :grade, :has_relations, :subject,
                    :subject_doc, :parent, :parent_guid

      alias_method :descr, :description

      def initialize(data)
        data = data["data"] if data["data"]
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

        # Parent guid extraction can be a little more complicated. Thanks AB!
        if data["parent"] && data["parent"].is_a?(String)
          @parent_guid = data["parent"]
        elsif data["parent"] && data["parent"].is_a?(Hash)
          @parent_guid = data["parent"]["guid"]
        end
      end

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
        unless child.is_a?(Standard)
          raise ArgumentError.new("Tried to set child that isn't a Standard")
        end
        @children.push(child)
      end

      def remove_child(child)
        @children.delete(child)
      end

      def has_children?
        @children.count > 0
      end

      private

      def attr_to_val_or_nil(klass, hash, attr)
        return nil unless hash.has_key?(attr)
        klass.from_hash(hash)
      end
    end
  end
end
