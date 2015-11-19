require_relative '../lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Subject
      include InstVarsToHash

      attr_accessor :code, :broad

      def self.from_hash(hash)
        self.new(code: hash["code"], broad: hash["broad"], )
      end

      def initialize(code:, broad:)
        @code = code
        @broad = broad
      end
    end
  end
end
