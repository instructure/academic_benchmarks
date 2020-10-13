require 'academic_benchmarks/api/constants'
require 'academic_benchmarks/api/standards'

module AcademicBenchmarks
  module Api
    class Handle
      include HTTParty

      attr_accessor :partner_id, :partner_key

      attr_reader :user_id # user_id writer is defined below

      base_uri AcademicBenchmarks::Api::Constants.base_url

      # Allows the user to initialize from environment variables
      def self.init_from_env
        partner_id  = partner_id_from_env
        partner_key = partner_key_from_env

        if !partner_id.present? || !partner_key.present?
          pidstr = !partner_id.present? ?
            AcademicBenchmarks::Api::Constants.partner_id_env_var : ""
          pkystr = !partner_key.present? ?
            AcademicBenchmarks::Api::Constants.partner_key_env_var : ""
          raise StandardError.new(
            "Missing environment variable(s): #{[pidstr, pkystr].join(', ')}"
          )
        end

        new(
          partner_id: partner_id,
          partner_key: partner_key,
          user_id: user_id_from_env
        )
      end

      def initialize(partner_id:, partner_key:, user_id: "")
        @partner_id = partner_id
        @partner_key = partner_key
        @user_id = user_id.to_s
      end

      def user_id=(user_id)
        @user_id = user_id.to_s
      end

      def standards
        Standards.new(self)
      end

      private

      def api_resp_to_array_of_standards(api_resp)
        api_resp.parsed_response["resources"].inject([]) do |retval, resource|
          retval.push(AcademicBenchmarks::Standards::Standard.new(resource["data"]))
        end
      end

      def self.partner_id_from_env
        ENV[AcademicBenchmarks::Api::Constants.partner_id_env_var]
      end

      def self.partner_key_from_env
        ENV[AcademicBenchmarks::Api::Constants.partner_key_env_var]
      end

      def self.user_id_from_env
        ENV[AcademicBenchmarks::Api::Constants.user_id_env_var]
      end
    end
  end
end
