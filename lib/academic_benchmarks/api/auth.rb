require 'active_support/core_ext/numeric/time'

module AcademicBenchmarks
  module Api
    module Auth
      def self.auth_query_params(partner_id:, partner_key:, expires:, user_id: "")
        {
          "partner.id" => partner_id,
          "auth.signature" => signature_for(
            partner_key: partner_key,
            message: self.message(expires: expires, user_id: user_id)
          ),
          "auth.expires" => expires
        }.tap do |params|
          params["user.id"] = user_id unless user_id.empty?
        end
      end

      def self.signature_for(partner_key:, message:)
        Base64.encode64(OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('sha256'),
          partner_key,
          message
        )).chomp
      end

      def self.message(expires:, user_id: '')
        if user_id.empty?
          "#{expires}"
        else
          "#{expires}\n#{user_id}"
        end
      end

      def self.expire_time_in_10_seconds
        self.expire_time_in(10.seconds)
      end

      def self.expire_time_in_2_hours
        self.expire_time_in(2.hours)
      end

      def self.expire_time_in(offset)
        Time.now.to_i + offset.to_i
      end
    end
  end
end
