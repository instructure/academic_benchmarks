require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Number
      include InstVarsToHash

      attr_accessor :enhanced, :raw

      def self.from_hash(hash)
        self.new(
          enhanced: hash["enhanced"],
          raw: hash["raw"]
        )
      end

      def initialize(enhanced:, raw:)
        @enhanced = enhanced
        @raw = raw
      end
    end
  end
end
