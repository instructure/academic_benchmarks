require 'academic_benchmarks/lib/attr_to_vals'
require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Disciplines
      include AttrToVals
      include InstVarsToHash

      attr_accessor :subjects

      def self.from_hash(hash)
        self.new(subjects: hash["subjects"])
      end

      def initialize(subjects:)
        @subjects = attr_to_vals(Subject, subjects)
      end
    end
  end
end