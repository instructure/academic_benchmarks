require_relative '../lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Document
      include InstVarsToHash

      attr_accessor :title, :guid

      def self.from_hash(hash)
        self.new(title: hash["title"], guid: hash["guid"])
      end

      def initialize(title:, guid:)
        @title = title
        @guid = guid
      end
    end
  end
end
