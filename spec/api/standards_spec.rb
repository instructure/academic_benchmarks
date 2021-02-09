RSpec.describe Standards do
  let(:handle) { ApiHelper::Live.new_handle }

  CC_STDS_COUNT_WITH_EXAMPLES = 2454
  CC_STDS_COUNT_WITHOUT_EXAMPLES = 2333

  # can also name the cassette: context "something", vcr: { cassette_name: "authorities" } do
  context "authorities", :vcr do
    it "lists authorities properly" do
      auths = handle.standards.authorities
      expect(auths).to be_a(Array)
      expect(auths.count).to be > 0
      expect(auths.any? do |a|
        a.code == ApiHelper::Live.known_present_authority
      end).to be_truthy
    end
  end

  context "publications", :vcr do
    context "by authority", vcr: { cassette_name: "publications_by_authority" } do
      it "lists publications by authority" do
        auth = handle.standards.authorities.find{|a| a.code == "CC"}
        expect(auth).to be_an(Authority)

        auth_pubs = handle.standards.authority_publications(auth)
        expect(auth_pubs.count).to eq(1)
        expect(auth_pubs.first.descr).to match(/common.core.state.standards/i)
      end

      it "lists by right authority with either code, guid, or auth object" do
        auth = handle.standards.authorities.find{|a| a.code == "CC"}
        expect(auth).to be_an(Authority)

        ap1 = handle.standards.authority_publications(auth)
        ap2 = handle.standards.authority_publications(auth.code)

        expect(ap1.count).to eq(1)
        expect(ap2.count).to eq(1)

        expect(ap1.first.descr).to eq(ap2.first.descr)
        expect(ap1.first.guid).to eq(ap2.first.guid)
      end
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

    it "provides access to authorities" do
      expect(s).to respond_to(:authorities)
    end

    it "provides access to publications" do
      expect(s).to respond_to(:publications)
    end

    context "provides trees" do
      it "provides a tree for an authority" do
        expect(s).to respond_to(:authority_tree)
      end

      it "provides a tree for a publication" do
        expect(s).to respond_to(:publication_tree)
      end
    end
  end

  context "trees", :vcr do
    def count_standards(tree)
      count = 0
      children = tree.children.dup
      while !children.empty? do
        child = children.pop
        count +=1 if child.is_a? Standard
        children.push(*child.children)
      end
      count
    end

    context "builds authority trees", vcr: { cassette_name: "api-standards-builds-authority-tree" } do
      it "builds an authority tree" do
        auth = handle.standards.authorities.find {|a| a.acronym == 'CC'}
        expect(auth).to be_a(Authority)
        expect(auth.children.count).to be_zero
        auth_tree = handle.standards.authority_tree(auth)
        expect(auth_tree).to be_a(StandardsTree)
        expect(auth_tree.root).to be_a(Authority)
        expect(count_standards(auth_tree)).to eq CC_STDS_COUNT_WITH_EXAMPLES
      end
    end

    it "excludes example standards in authority tree" do
      auth = handle.standards.authorities.find {|a| a.acronym == 'CC'}
      auth_tree = handle.standards.authority_tree(auth, exclude_examples: true)
      expect(count_standards(auth_tree)).to eq CC_STDS_COUNT_WITHOUT_EXAMPLES
    end

    context "builds publication tree", vcr: { cassette_name: "api-standards-builds-publication-tree" } do
      it "builds a publication tree" do
        pub = handle.standards.publications.find {|p| p.acronym=='CCSS'}
        expect(pub).to be_a(Publication)
        expect(pub.children.count).to be_zero
        pub_tree = handle.standards.publication_tree(pub)
        expect(pub_tree).to be_a(StandardsTree)
        expect(pub_tree.root).to be_a(Publication)
        expect(count_standards(pub_tree)).to eq CC_STDS_COUNT_WITH_EXAMPLES
      end
    end

    it "excludes example standards in publication tree" do
      pub = handle.standards.publications.find {|p| p.acronym == 'CCSS'}
      pub_tree = handle.standards.publication_tree(pub, exclude_examples: true)
      expect(count_standards(pub_tree)).to eq CC_STDS_COUNT_WITHOUT_EXAMPLES
    end

    context "searching and matching authorities" do
      let(:standards_stub) do
        ->(method:, retval:) do
          s = ApiHelper::Live.new_handle.standards
          allow(s).to receive(method) { retval }
          s
        end
      end

      authority_range = (0..9)

      authority_range.each do |num|
        let(:"authority_#{num}") do
          # Authority will follow this pattern (example given for num == 1)
          #   acronym: "BB"
          #   guid: "1111111111"
          #   descr: "authority '1'"
          Authority.new(
            acronym: "#{('A'.ord + num).chr * 2}",
            guid: "#{num.to_s * 10}",
            descr: "authority '#{num}'"
          )
        end
      end

      let(:authority_array) do
        authority_range.inject([]) do |acc, num|
          acc.push(send(:"authority_#{num}"))
          acc
        end
      end

      context "errors searching for authorities" do
        it "errors if multiple authorities match the query" do
          authority_2.acronym = authority_1.acronym
          ss = standards_stub.call(
            method: :match_authority,
            retval: [ authority_1, authority_2 ]
          )
          expect{
            ss.send(:find_type, type: "authority", data: authority_1.acronym)
          }.to raise_error(StandardError, /more than one/i)
        end

        it "errors if no authorities match the query" do
          ss = standards_stub.call(
            method: :match_authority,
            retval: []
          )
          expect{
            ss.send(:find_type, type: "authority", data: "ISHOULDNOTEXIST")
          }.to raise_error(StandardError, /no authority.*matched/i)
        end
      end

      context "matching authorities" do
        let(:ss_with_auth_array) do
          standards_stub.call(
            method: :authorities,
            retval: authority_array
          )
        end

        it "matches authorities by acronym" do
          bb = ss_with_auth_array.send(:match_authority, 'BB')
          expect(bb).to be_a(Array)
          expect(bb.count).to eq(1)
          expect(bb.first.acronym).to eq('BB')
        end

        it "matches authorities by guid" do
          bb = ss_with_auth_array.send(:match_authority, "#{'4' * 10}")
          expect(bb).to be_a(Array)
          expect(bb.count).to eq(1)
          expect(bb.first.acronym).to eq('EE')
        end

        it "matches authorities by description" do
          bb = ss_with_auth_array.send(:match_authority, "authority '6'")
          expect(bb).to be_a(Array)
          expect(bb.count).to eq(1)
          expect(bb.first.acronym).to eq('GG')
        end
      end
    end

    it "matches real authority by guid" do
      auths = handle.standards.authorities
      common_core = auths.find{ |a| a.code == "CC" }
      expect(common_core).not_to be_nil
      expect(common_core).to be_an(Authority)
      expect(common_core.guid).not_to be_nil
      expect(common_core.guid).to be_a(String)
      expect(common_core.guid).not_to be_empty
      matches = handle.standards.send(:match_authority, common_core.guid)
      expect(matches).to be_an(Array)
      expect(matches.count).to eq(1)
      expect(matches.first.code).to eq(common_core.code)
      expect(matches.first.guid).to eq(common_core.guid)
      expect(matches.first.description).to eq(common_core.description)
    end
  end

  context "retry" do
    it "retries once" do
      mock_once = true

      expect(handle.class).to receive(:get).twice {
        # return 429 first, then 200 afterwards
        instance_double(
          HTTParty::Response,
          code: mock_once ? 429 : 200,
          parsed_response: {"data" => [], "meta" => {"facets" => [{"details" => []}]}},
          headers: {}
        ).tap do
          mock_once = false
        end
      }

      handle.standards.authorities
    end
  end
end
