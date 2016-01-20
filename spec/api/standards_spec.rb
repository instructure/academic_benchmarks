RSpec.describe Standards do
  let(:handle) { ApiHelper::Live.new_handle }

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

  context "documents", :vcr do
    context "by authority", vcr: { cassette_name: "documents_by_authority" } do
      it "lists documents by authority" do
        auth = handle.standards.authorities.find{|a| a.code == "CC"}
        expect(auth).to be_an(Authority)

        auth_docs = handle.standards.authority_documents(auth)
        expect(auth_docs.count).to eq(1)
        expect(auth_docs.first.title).to match(/common.core.state.standards/i)
      end

      it "lists by right authority with either code, guid, or auth object" do
        auth = handle.standards.authorities.find{|a| a.code == "CC"}
        expect(auth).to be_an(Authority)

        ad1 = handle.standards.authority_documents(auth)
        ad2 = handle.standards.authority_documents(auth.code)

        expect(ad1.count).to eq(1)
        expect(ad2.count).to eq(1)

        expect(ad1.first.title).to eq(ad2.first.title)
        expect(ad1.first.guid).to eq(ad2.first.guid)
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

    it "provides access to documents" do
      expect(s).to respond_to(:documents)
    end

    it "provides access to authorities" do
      expect(s).to respond_to(:authorities)
    end

    context "provides trees" do
      it "provides a tree for an authority" do
        expect(s).to respond_to(:authority_tree)
      end

      it "provides a tree for a document" do
        expect(s).to respond_to(:document_tree)
      end
    end
  end

  context "trees", :vcr do
    context "builds authority trees", vcr: { cassette_name: "api-standards-builds-authority-tree" } do
      it "builds an authority tree" do
        auth = handle.standards.authorities.first
        expect(auth).to be_a(Authority)
        expect(auth.children.count).to be_zero
        auth_tree = handle.standards.authority_tree(auth)
        expect(auth_tree).to be_a(StandardsTree)
        expect(auth_tree.root).to be_a(Authority)
        expect(auth_tree.children.count).to be > 0
      end
    end

    context "builds document tree", vcr: { cassette_name: "api-standards-builds-document-tree" } do
      it "builds a document tree" do
        docs = handle.standards.documents.first
        expect(docs).to be_a(Document)
        expect(docs.children.count).to be_zero
        doc_tree = handle.standards.document_tree(docs)
        expect(doc_tree).to be_a(StandardsTree)
        expect(doc_tree.root).to be_a(Document)
        expect(doc_tree.children.count).to be > 0
      end
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
          #   code: "BB"
          #   guid: "1111111111"
          #   description: "authority '1'"
          Authority.new(
            code: "#{('A'.ord + num).chr * 2}",
            guid: "#{num.to_s * 10}",
            description: "authority '#{num}'"
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
          authority_2.code = authority_1.code
          ss = standards_stub.call(
            method: :match_authority,
            retval: [ authority_1, authority_2 ]
          )
          expect{
            ss.send(:find_type, type: "authority", data: authority_1.code)
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

        it "matches authorities by code" do
          bb = ss_with_auth_array.send(:match_authority, 'BB')
          expect(bb).to be_a(Array)
          expect(bb.count).to eq(1)
          expect(bb.first.code).to eq('BB')
        end

        it "matches authorities by guid" do
          bb = ss_with_auth_array.send(:match_authority, "#{'4' * 10}")
          expect(bb).to be_a(Array)
          expect(bb.count).to eq(1)
          expect(bb.first.code).to eq('EE')
        end

        it "matches authorities by description" do
          bb = ss_with_auth_array.send(:match_authority, "authority '6'")
          expect(bb).to be_a(Array)
          expect(bb.count).to eq(1)
          expect(bb.first.code).to eq('GG')
        end
      end
    end

    it "matches real authority by guid" do
      auths = handle.standards.authorities
      indiana = auths.find{ |a| a.code == "IN" }
      expect(indiana).not_to be_nil
      expect(indiana).to be_an(Authority)
      expect(indiana.guid).not_to be_nil
      expect(indiana.guid).to be_a(String)
      expect(indiana.guid).not_to be_empty
      matches = handle.standards.send(:match_authority, indiana.guid)
      expect(matches).to be_an(Array)
      expect(matches.count).to eq(1)
      expect(matches.first.code).to eq(indiana.code)
      expect(matches.first.guid).to eq(indiana.guid)
      expect(matches.first.description).to eq(indiana.description)
    end
  end
end
