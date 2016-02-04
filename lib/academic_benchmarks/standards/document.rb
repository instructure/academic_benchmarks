require_relative '../lib/inst_vars_to_hash'
require_relative '../lib/remove_obsolete_children'

module AcademicBenchmarks
  module Standards
    class Document
      include InstVarsToHash
      include RemoveObsoleteChildren

      attr_accessor :title, :guid, :children

      def self.from_hash(hash)
        self.new(title: hash["title"], guid: hash["guid"])
      end

      def initialize(title:, guid:, children: [])
        @title = title
        @guid = guid
        @children = children
      end
    end
  end
end
