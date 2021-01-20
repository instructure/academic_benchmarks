require 'academic_benchmarks/lib/inst_vars_to_hash'

module AcademicBenchmarks
  module Standards
    class Document
      include InstVarsToHash

      attr_accessor :guid, :descr, :publication, :adopt_year, :children
      alias_method :description, :descr

      def self.from_hash(hash)
        self.new(guid: hash["guid"], descr: hash["descr"], publication: hash["publication"], adopt_year: hash["adopt_year"])
      end

      def initialize(guid:, descr:, publication:, adopt_year:, children: [])
        @guid = guid
        @descr = descr
        @publication = attr_to_val_or_nil(Publication, publication)
        @adopt_year = adopt_year
        @children = children
      end

      private

      def attr_to_val_or_nil(klass, hash)
        return nil if hash.nil?
        klass.from_hash(hash)
      end
    end
  end
end
