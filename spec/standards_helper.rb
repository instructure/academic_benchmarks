require 'securerandom'

module StandardsHelper
  def self.standard_hash
    JSON.parse(ApiHelper::Fixtures.search_authority_indiana_response)['data'].first
  end

  def self.standard
    Standard.new(self.standard_hash).tap{|s| s.guid = SecureRandom.uuid}
  end
end
