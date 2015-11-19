RSpec.describe StandardsForest do
  let(:real_api_response) do
    JSON.parse(ApiHelper.search_authority_indiana_response)
  end

  let(:search_dummy_2) do
    JSON.parse(ApiHelper.search_authority_dummy_response_depth_2)
  end

  let(:search_dummy_3) do
    JSON.parse(ApiHelper.search_authority_dummy_response_depth_3)
  end

  let(:search_dummy_4) do
    JSON.parse(ApiHelper.search_authority_dummy_response_depth_4)
  end

  it "doesn't choke on real data" do
    sforest = StandardsForest.new(real_api_response)
    expect(sforest.trees.count).not_to eq(0)
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

  it "properly builds a tree" do
    sforest = StandardsForest.new(search_dummy_2, save_initial_data_hash: true)
    expect(sforest.trees.count).to eq(1)
    expect(sforest.trees.first.root_standard.children.count).to eq(3)
    expect(sforest.trees.first.root_standard.guid).to eq("5f516f0b-4207-4852-8393-b55cd9e0ed53")
    child_guids = %w[
      7e20d3b6-b0cd-4776-8cdc-8250981062d7
      532d0044-cc1b-4d3f-8733-e888a03fb130
      8e479904-40e2-461f-9cdb-7e3650fe9004
    ]
    sforest.trees.first.root_standard.children.each do |child|
      expect(child).not_to have_children
      expect(child_guids).to include(child.guid)
      child_guids.delete(child.guid)
    end
    expect(child_guids).to be_empty
  end
end
