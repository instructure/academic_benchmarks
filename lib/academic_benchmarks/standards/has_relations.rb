require_relative '../lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class HasRelations
      include InstVarsToHash

      attr_accessor :origin, :derivative, :related_derivative

      def self.from_hash(hash)
        self.new(derivative: hash["derivative"], origin: hash["origin"], related_derivative: hash["related_derivative"])
      end

      def initialize(origin: 0, derivative: 0, related_derivative: 0)
        @origin = origin
        @derivative = derivative
        @related_derivative = related_derivative
      end
    end
  end
end
