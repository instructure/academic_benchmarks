RSpec.describe Standards do
  it "rejects search parameters that are not valid" do
    valid_params = AcademicBenchmarks::Api::Constants.standards_search_params
    invalid_params = %w[ice hurricane wind snow avalanche tornado tsunami]

    s = Standards.new(nil)
    invalid_params.each do |p|
      expect{
        s.search({p.to_s => 100})
      }.to raise_error(ArgumentError, /invalid.search.params.*#{p}/i)
    end
    expect{
      s.search(invalid_params.map{|p| [p, 100]}.to_h)
    }.to raise_error(ArgumentError, /invalid.search.params/i)
  end

  context "authorities" do
    it "lists authorities properly" do
      {"data"=>{"authority"=>{"guid"=>"A8334A58-901A-11DF-A622-0C319DFF4B22", "descr"=>"Indiana", "code"=>"IN"}}}
      {"data"=>{"authority"=>{"guid"=>"A83297F2-901A-11DF-A622-0C319DFF4B22", "descr"=>"NGA Center/CCSSO", "code"=>"CC"}}}
      {"data"=>{"authority"=>{"guid"=>"A834F40C-901A-11DF-A622-0C319DFF4B22", "descr"=>"Ohio", "code"=>"OH"}}}
    end
  end

  it "requires a positive integer limit" do
    err_klass = ArgumentError
    err_regex = /limit.must.be.*positive.integer/

    s = Standards.new(nil)
    expect{
      s.send('request_search_pages_and_concat_resources', {limit: nil})
    }.to raise_error(err_klass, err_regex)
    expect{
      s.send('request_search_pages_and_concat_resources', {limit: 0})
    }.to raise_error(err_klass, err_regex)
    expect{
      s.send('request_search_pages_and_concat_resources', {limit: -1})
    }.to raise_error(err_klass, err_regex)

    #
    # RSpec complains about the next test being a potential false positive,
    # but this is a false positive about a false positive :-)
    #
    prev_val = RSpec::Expectations.configuration.warn_about_potential_false_positives?
    RSpec::Expectations.configuration.warn_about_potential_false_positives = false

    expect{
      s.send('request_search_pages_and_concat_resources', {limit: 1})
    }.not_to raise_error(err_klass, err_regex)

    RSpec::Expectations.configuration.warn_about_potential_false_positives = prev_val
  end

  context "responds to methods" do
    let(:s) { Standards.new(nil) }

    it "provides access to documents" do
      expect(s).to respond_to(:documents)
    end

    it "provides access to authorities" do
      expect(s).to respond_to(:authorities)
    end
  end
end
