require 'academic_benchmarks/lib/attr_to_vals'
require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Publication
      include AttrToVals
      include InstVarsToHash

      attr_accessor :acronym, :descr, :guid, :authorities, :children

      alias_method :code, :acronym
      alias_method :description, :descr

      def self.from_hash(hash)
        self.new(
          acronym: hash["acronym"],
          descr: hash["descr"],
          guid: hash["guid"],
          authorities: hash["authorities"]
        )
      end

      def initialize(acronym:, descr:, guid:, authorities:, children: [])
        @acronym = acronym
        @descr = descr
        @guid = guid
        @authorities = attr_to_vals(Authority, authorities)
        @children = children
      end

      # Children are standards, so rebranch them so we have
      # the following structure:
      #
      #   Publication -> Document -> Section -> Standard
      def rebranch_children
        @seen = Set.new()
        @guid_to_obj = {}
        new_children = []
        @children.each do |child|
          doc = reparent(child.document, new_children)
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