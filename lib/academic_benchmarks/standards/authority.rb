require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Authority
      include InstVarsToHash

      attr_accessor :acronym, :descr, :guid, :children

      alias_method :code, :acronym
      alias_method :description, :descr

      def self.from_hash(hash)
        self.new(
          acronym: hash["acronym"],
          guid: hash["guid"],
          descr: hash["descr"]
        )
      end

      def initialize(acronym:, guid:, descr:, children: [])
        @acronym = acronym
        @guid = guid
        @descr = descr
        @children = children
      end

      # Children are standards, so rebranch them so we have
      # the following structure:
      #
      #   Authority -> Publication -> Document -> Section -> Standard
      def rebranch_children
        @seen = Set.new()
        @guid_to_obj = {}
        new_children = []
        @children.each do |child|
          pub = reparent(child.document.publication, new_children)
          doc = reparent(child.document, pub.children)
          sec = reparent(child.section, doc.children)
          sec.children.push(child)
        end
        @children.replace(new_children)
        remove_instance_variable('@seen')
        remove_instance_variable('@guid_to_obj')
      end

      private

      def reparent(object, children)
        cached_object = (@guid_to_obj[object.guid] ||= object)
        children.push(cached_object) if @seen.add? cached_object.guid
        cached_object
      end
    end
  end
end
