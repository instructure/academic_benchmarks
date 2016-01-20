RSpec.describe StandardsForest do
  let(:ab) { ApiHelper::Live.new_handle }

  context "dummy data" do
    let(:search_dummy_2) do
      JSON.parse(ApiHelper::Fixtures.search_authority_dummy_response_depth_2)
    end

    let(:search_dummy_3) do
      JSON.parse(ApiHelper::Fixtures.search_authority_dummy_response_depth_3)
    end

    let(:search_dummy_4) do
      JSON.parse(ApiHelper::Fixtures.search_authority_dummy_response_depth_4)
    end

    context "initial data hash" do
      it "saves the initial data hash when told to" do
        sforest = StandardsForest.new(search_dummy_4, save_initial_data_hash: true)
        expect(sforest.data_hash).not_to be_nil
      end

      it "does not save the initial data hash when told not to" do
        sforest = StandardsForest.new(search_dummy_4, save_initial_data_hash: false)
        expect(sforest.data_hash).to be_nil
      end
    end

    it "properly builds a tree (dummy data)" do
      sforest = StandardsForest.new(search_dummy_2, save_initial_data_hash: true)
      expect(sforest.trees.count).to eq(1)
      expect(sforest.trees.first.root.children.count).to eq(3)
      expect(sforest.trees.first.root.guid).to eq("5f516f0b-4207-4852-8393-b55cd9e0ed53")
      child_guids = %w[
        7e20d3b6-b0cd-4776-8cdc-8250981062d7
        532d0044-cc1b-4d3f-8733-e888a03fb130
        8e479904-40e2-461f-9cdb-7e3650fe9004
      ]
      sforest.trees.first.root.children.each do |child|
        expect(child).not_to have_children
        expect(child_guids).to include(child.guid)
        child_guids.delete(child.guid)
      end
      expect(child_guids).to be_empty
    end
  end

  context "real data" do
    context "fixtures" do
      let(:real_api_response) do
        JSON.parse(ApiHelper::Fixtures.search_authority_indiana_response)
      end

      let(:authority) do
        Authority.new({
          code: "BP",
          guid: "you-aint-seen-nothin-yet",
          description: "B-b-b-baby, you just ain't seen n-n-nothin' yet" 
        })
      end

      it "doesn't choke on real data (fixture)" do
        sforest = StandardsForest.new(real_api_response)
        expect(sforest.trees.count).not_to eq(0)
      end

      context "forest consolidation (fixtures)" do
        let(:consolidated_forest) do
          sforest = StandardsForest.new(real_api_response)
          sforest.consolidate_under_root(authority)
        end

        it "consolidates a forest under an authority" do
          sforest = StandardsForest.new(real_api_response)
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
        retval = ab.standards.authorities.first
        expect(retval).to be_a(Authority)
        retval
      end

      let(:valid_document) do
        # Use common core since it should always children
        retval = ab.standards.documents.find{|d| d.title =~ /common.core/i}
        expect(retval).to be_a(Document)
        retval
      end

      let(:sforest_auth) do
        StandardsForest.new(ab.standards.search(authority: valid_authority.code))
      end

      let(:sforest_doc) do
        StandardsForest.new(ab.standards.search(document: valid_document.guid))
      end

      it "turns an authority search into a forest" do
        expect(sforest_auth.trees.count).to be > 0
      end

      it "turns a document search into a tree" do
        expect(sforest_doc.trees.count).to be > 0
        expect(sforest_doc.trees.first.root.children.count).to be > 0
        expect(sforest_doc.trees.first.root.children.first.children.count).to be > 0
      end

      context "consolidation of a forest" do
        it "consolidates a forest under a document" do
          doc_tree = sforest_doc.consolidate_under_root(valid_document)
          expect(doc_tree).to be_a(StandardsTree)
          expect(doc_tree.root).to be_a(Document)
          expect(doc_tree.root.guid).to eq(valid_document.guid)
          expect(doc_tree.root.title).to eq(valid_document.title)
          expect(doc_tree.children.count).to eq(sforest_doc.trees.count)
        end
      end
    end
  end
end
