require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Statement
      include InstVarsToHash

      attr_accessor :descr

      alias_method :description, :descr

      def self.from_hash(hash)
        self.new(descr: hash["descr"])
      end

      def initialize(descr:)
        @descr = descr
      end
    end
  end
end
