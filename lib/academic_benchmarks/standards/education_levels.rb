require 'academic_benchmarks/lib/attr_to_vals'
require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class EducationLevels
      include AttrToVals
      include InstVarsToHash

      attr_accessor :grades

      def self.from_hash(hash)
        self.new(grades: hash["grades"])
      end

      def initialize(grades:)
        @grades = attr_to_vals(Grade, grades)
      end
    end
  end
end
