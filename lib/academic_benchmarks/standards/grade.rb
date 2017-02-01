require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Grade
      include InstVarsToHash

      attr_accessor :high, :low

      def self.from_hash(hash)
        self.new(high: hash["high"], low: hash["low"])
      end

      def initialize(high:, low:)
        @high = high
        @low = low
      end
    end
  end
end
