require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Subject
      include InstVarsToHash

      attr_accessor :code

      def self.from_hash(hash)
        self.new(code: hash["code"])
      end

      def initialize(code:)
        @code = code
      end
    end
  end
end
