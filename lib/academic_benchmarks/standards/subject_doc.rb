require_relative '../lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class SubjectDoc
      include InstVarsToHash

      attr_accessor :guid, :description

      alias_method :descr, :description

      def self.from_hash(hash)
        self.new(guid: hash["guid"], description: hash["descr"])
      end

      def initialize(guid:, description:)
        @guid = guid
        @description = description
      end
    end
  end
end
