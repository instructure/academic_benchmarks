require_relative '../lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Parent
      include InstVarsToHash

      attr_accessor :guid, :description, :number, :stem, :label, :deepest,
                    :seq, :level, :status, :version

      def self.from_hash(hash)
        self.new(
          guid: hash["guid"],
          description: hash["description"],
          number: hash["number"],
          stem: hash["stem"],
          label: hash["label"],
          deepest: hash["deepest"],
          seq: hash["seq"],
          level: hash["level"],
          status: hash["status"],
          version: hash["version"]
        )
      end

      def initialize(guid:, description:, number:, stem:, label:, deepest:,
                     seq:, level:, status:, version:)
        @guid = guid
        @description = description
        @number = number
        @stem = stem
        @label = label
        @deepest = deepest
        @seq = seq
        @level = level
        @status = status
        @version = version
      end
    end
  end
end
