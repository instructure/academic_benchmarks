require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Course
      include InstVarsToHash

      attr_accessor :guid, :description

      alias_method :descr, :description

      def self.from_hash(hash)
        self.new(description: hash["descr"], guid: hash["guid"])
      end

      def initialize(guid:, description:)
        @guid = guid
        @description = description
      end
    end
  end
end
