require_relative '../lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Authority
      include InstVarsToHash

      attr_accessor :code, :guid, :description, :children

      alias_method :descr, :description

      def self.from_hash(hash)
        self.new(code: hash["code"], guid: hash["guid"], description: hash["descr"])
      end

      def initialize(code:, guid:, description:, children: [])
        @code = code
        @guid = guid
        @description = description
        @children = children
      end
    end
  end
end
