module ApiHelper
  PARTNER_ID = "bestpartnerever".freeze
  PARTNER_KEY = "wV8qUjlTxDcVdFSgCOyO5g".freeze
  USER_ID = "122381".freeze

  def self.all_standards_response
    File.read(File.expand_path(
      "#{File.dirname(__FILE__)}/fixtures/api_all_standards_response.json"
    ))
  end

  def self.search_authority_indiana_response
    File.read(File.expand_path(
      "#{File.dirname(__FILE__)}/fixtures/api_search_authority_indiana_response.json"
    ))
  end

  def self.search_authority_dummy_response_depth_2
    File.read(File.expand_path(
      "#{File.dirname(__FILE__)}/fixtures/api_search_authority_dummy_response_depth_2.json"
    ))
  end

  def self.search_authority_dummy_response_depth_3
    File.read(File.expand_path(
      "#{File.dirname(__FILE__)}/fixtures/api_search_authority_dummy_response_depth_3.json"
    ))
  end

  def self.search_authority_dummy_response_depth_4
    File.read(File.expand_path(
      "#{File.dirname(__FILE__)}/fixtures/api_search_authority_dummy_response_depth_4.json"
    ))
  end
end
