module StandardsHelper
  def self.standard_hash
    JSON.parse(ApiHelper.search_authority_indiana_response).first
  end

  def self.standard
    self.standard_hash
  end
end
