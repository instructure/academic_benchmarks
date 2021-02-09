require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Number
      include InstVarsToHash

      attr_accessor :prefix_enhanced

      def self.from_hash(hash)
        self.new(
          prefix_enhanced: hash["prefix_enhanced"]
        )
      end

      def initialize(prefix_enhanced:)
        @prefix_enhanced = prefix_enhanced
      end
    end
  end
end
