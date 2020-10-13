RSpec.describe StandardsForest do

  def available_or_fail(standards)
    return true if ApiHelper::Live.standards_available?(standards)

    pending "This test requires the #{standards} standards to be part " \
            "of the subscription"
    fail
  end

  let(:ab) { ApiHelper::Live.new_handle }

  context "real data" do
    context "fixtures" do
      let(:real_api_response) do
        JSON.parse(ApiHelper::Fixtures.search_authority_indiana_response)
      end

      let(:authority) do
        Authority.new(
          acronym: "AC",
          guid: "auth-guid",
          descr: "auth-description" 
        )
      end

      it "doesn't choke on real data (fixture)" do
        sforest = StandardsForest.new(real_api_response["data"])
        expect(sforest.trees.count).not_to eq(0)
      end

      it "properly builds a tree (dummy data)" do
        sforest = StandardsForest.new(real_api_response['data'])
        expect(sforest.trees.count).to eq(9)
        expect(sforest.trees[3].root.children.count).to eq(3)
        expect(sforest.trees[3].root.guid).to eq("00635d8a-2ef3-11e8-8bb2-0a11cde56ade")
        child_guids = %w[
          00645127-2ef3-11e8-8bb2-0a11cde56ade
          00676196-2ef3-11e8-8bb2-0a11cde56ade
          006ac86e-2ef3-11e8-8bb2-0a11cde56ade
        ]
        sforest.trees[3].root.children.each do |child|
          # expect(child).not_to have_children
          expect(child_guids).to include(child.guid)
          child_guids.delete(child.guid)
        end
        expect(child_guids).to be_empty
      end

      context "forest consolidation (fixtures)" do
        let(:consolidated_forest) do
          sforest = StandardsForest.new(real_api_response["data"])
          sforest.consolidate_under_root(authority)
        end

        it "consolidates a forest under an authority" do
          sforest = StandardsForest.new(real_api_response["data"])
          expect(sforest).not_to be_empty
          expect(sforest.trees.count).to be > 5
          consolidated_tree = sforest.consolidate_under_root(authority)
          expect(consolidated_tree).to be_a(StandardsTree)
          expect(consolidated_tree.root).to be_a(Authority)
          expect(consolidated_tree.children.count).not_to be_zero
        end

        it "consolidates to valid json with no parents (parent guids are ok)" do
          check_key = ->(key) do
            expect(key).to be_a(String)
            expect(key).not_to match(/^parent$/i)
          end

          json = consolidated_forest.to_json
          expect(json).to be_a(String)
          hash = nil
          expect{hash = JSON.parse(json)}.not_to raise_error
          expect(hash).not_to be_nil
          hash.each_key do |key|
            check_key.call(key)
          end
        end
      end
    end

    context "live data (vcr)", :vcr do
      let(:valid_authority) do
        retval = ab.standards.authorities.find{|d| d.acronym == 'CC'}
        expect(retval).to be_a(Authority)
        retval
      end

      let(:valid_publication) do
        # Use common core since it should always children
        retval = ab.standards.publications.find{|d| d.acronym == 'CCSS'}
        expect(retval).to be_a(Publication)
        retval
      end

      let(:sforest_auth) do
        StandardsForest.new(ab.standards.search(authority_guid: valid_authority.guid))
      end

      let(:sforest_pub) do
        StandardsForest.new(ab.standards.search(publication_guid: valid_publication.guid))
      end

      it "turns an authority search into a forest" do
        expect(sforest_auth.trees.count).to be > 0
      end

      it "turns a publication search into a tree" do
        expect(sforest_pub.trees.count).to be > 0
        expect(sforest_pub.trees.last.root.children.count).to be > 0
        expect(sforest_pub.trees.last.root.children.first.children.count).to be > 0
      end

      context "consolidation of a forest" do
        it "consolidates a forest under a publication" do
          pub_tree = sforest_pub.consolidate_under_root(valid_publication)
          expect(pub_tree).to be_a(StandardsTree)
          expect(pub_tree.root).to be_a(Publication)

          expect(pub_tree.root.guid).to eq(valid_publication.guid)
          expect(pub_tree.root.descr).to eq(valid_publication.descr)
          expect(pub_tree.children.map {|doc| doc.children.map {|sec| sec.children}.flatten}.flatten.count).to eq(sforest_pub.trees.count)
        end

        it "doesn't die when consolidating the Utah standards", vcr: {cassette_name: "utah_standards_forest"} do
          # This test can only be run if the Utah standards are part of the subscription
          if available_or_fail("Utah State Board of Education")
            expect {
              ab.standards.authority_tree("Utah State Board of Education")
            }.not_to raise_error
          end
        end
      end
    end
  end
end
