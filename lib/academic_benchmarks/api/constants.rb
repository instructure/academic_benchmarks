module AcademicBenchmarks
  module Api
    module Constants
      def self.base_url
        'https://api.abconnect.certicaconnect.com/rest/v4.1'
      end

      def self.api_version
        '4.1'
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
    end
  end
end
