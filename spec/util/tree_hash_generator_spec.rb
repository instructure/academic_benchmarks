require_relative '../../util/tree_hash_generator'

RSpec.describe TreeHashGenerator do
  context "new standard" do
    let(:number) { 198437 }
    let(:guid) { SecureRandom.uuid }
    let(:descr) { "Here we go round the mulberry bush" }
    let(:base_self_url) do
      "http://api.academicbenchmarks.com/rest/v3/standards"
    end
    let(:self_url) do
      "#{base_self_url}/#{guid}"
    end

    it "creates a new standard with specified data" do
      new_standard_data = TreeHashGenerator.new_standard(
        number: number,
        guid: guid,
        descr: descr,
        parent: guid
      )["data"]

      expect(new_standard_data).not_to be_nil
      expect(new_standard_data["number"]).to eq("1.#{number}")
      expect(new_standard_data["guid"]).to eq(guid)
      expect(new_standard_data["descr"]).to eq(descr)
      expect(new_standard_data["self"]).to eq(self_url)
      expect(new_standard_data["parent"]).to eq(guid)
    end

    it "creates a new standard with sane default data" do
      new_standard_data = TreeHashGenerator.new_standard()["data"]

      expect(new_standard_data).not_to be_nil
      expect(new_standard_data["number"]).to match(/1\.\d{4,}/i)
      expect(new_standard_data["guid"]).to match(/[0-9a-f\-]{20,}/i)
      expect(new_standard_data["descr"]).to eq(
        "This description is for standard number " \
        "#{new_standard_data["number"]}"
      )
      expect(new_standard_data["self"]).to eq(
        "#{base_self_url}/#{new_standard_data["guid"]}"
      )
      expect(new_standard_data["parent"]).to be_nil
    end
  end

  context "new tree" do
    it "creates a valid tree with correct num children" do
      new_tree = TreeHashGenerator.new_tree(depth: 2, num_children: 3)
      expect(new_tree).to be_an(Array)
      expect(new_tree.count).to eq(4)
      expect(new_tree.first["data"]["parent"]).to be_nil
      (1..3).each do |i|
        expect(
          new_tree[i]["data"]["parent"]
        ).to eq(new_tree.first["data"]["guid"])
      end
    end

    context "tree depth" do
      # hash of depth to total number of elements in the array
      TREE_DEPTH_CASES = {
        2 => 4,
        3 => 13,
        4 => 40,
        5 => 121,
        6 => 364,
        7 => 1093,
        8 => 3280,
      }.freeze

      TREE_DEPTH_CASES.each do |depth, total|
        it "creates a tree of depth #{depth} with #{total} total items" do
          expect(TreeHashGenerator.new_tree(depth: depth, num_children: 3).count).to eq(total)
        end
      end
    end

    it "doesn't reuse guids" do
      used_guids = {}
      new_tree = TreeHashGenerator.new_tree(depth: 7)
      new_tree.each do |elem|
        expect(used_guids.keys).not_to include(elem["data"]["guid"])
        used_guids[elem["data"]["guid"]] = true
      end
    end
  end
end
