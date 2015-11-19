module AcademicBenchmarks
  module Api
    module Constants
      def self.base_url
        'https://api.academicbenchmarks.com/rest/v3'
      end

      def self.api_version
        '3'
      end

      def self.partner_id_env_var
        'ACADEMIC_BENCHMARKS_PARTNER_ID'
      end

      def self.partner_key_env_var
        'ACADEMIC_BENCHMARKS_PARTNER_KEY'
      end

      def self.user_id_env_var
        'ACADEMIC_BENCHMARKS_USER_ID'
      end

      def self.standards_search_params
        %w[
          query
          authority
          subject
          grade
          subject_doc
          course
          document
          parent
          deepest
          limit
          offset
          list
          fields
        ]
      end
    end
  end
end
