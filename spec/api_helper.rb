module ApiHelper
  module Fixtures
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
  end

  module Live
    def self.new_handle
      AcademicBenchmarks::Api::Handle.init_from_env
    end

    #
    # Common Core should be present in the sandbox account and a full subscription
    #
    def self.known_present_authority
      "CC"
    end

    def self.standards_available?(standards)
      handle = self.new_handle
      available = handle.standards.authorities.any? do |auth|
        auth.code == standards || auth.guid == standards || auth.description == standards
      end
      unless available
        available = handle.standards.publications.any? do |stan|
          stan.guid == standards || stan.descr == standards
        end
      end
      available
    end
  end
end
