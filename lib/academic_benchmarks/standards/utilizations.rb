require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Utilizations
      include InstVarsToHash

      attr_accessor :type

      def self.from_hash(hash)
        self.new(type: hash["type"])
      end

      def initialize(type:)
        @type = type
      end
    end
  end
end