require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir                    = 'spec/fixtures/vcr_cassettes'
  c.hook_into                               :webmock
  c.allow_http_connections_when_no_cassette = false
  c.configure_rspec_metadata!

  # If we don't do this, VCR will save some stuff in a binary format that
  # can't be understood by humans.  Strangely, the binary seems to produce
  # larger file sizes than UTF-8  ¯\_(ツ)_/¯  (i.e. 95K vs. 121K)
  c.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  record = ConfigHelper.run_live? ? :all : :new_episodes

  #
  # in the default cassette options, record: :new_episodes will just append
  # new requests to the cassette.  record: :once only allows the cassette
  # to be recorded once.  record: :all will force the entire thing to be
  # re-recorded.
  #
  # re_record_interval can be added here to have the cassettes
  # re-recorded after the interval is up.  In this case, 7 days
  #
  c.default_cassette_options = {
    record: record,
    #re_record_interval: 7.days,
    match_requests_on: [
      :method, VCR.request_matchers.uri_without_params(
        :"auth.expires",
        :"auth.signature",
        :"partner.id",
        :"user.id"
      )
    ]
  }
end
