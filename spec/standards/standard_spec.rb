RSpec.describe Standard do
  include ObjectHelper

  let(:api_response) do
    JSON.parse(ApiHelper::Fixtures.all_standards_response)
  end

  # poro == plain old ruby object
  let(:standard) { Standard.new(api_response["resources"].first) }
  let(:poro_keys) { %w[authority course document grade has_relations parent subject subject_doc] }
  let(:ignore_keys) { %w[self] }

  it "accepts only 'Active' and 'Obsolete' for status" do
    expect{standard.status = "Hello"}.to raise_error(ArgumentError)
    %w[Obsolete Active].each do |new_val|
      expect{standard.status = new_val}.to change{standard.status}.to(new_val)
      if standard.status == 'Active'
        expect(standard).to be_active
        expect(standard).not_to be_obsolete
      else
        expect(standard).to be_obsolete
        expect(standard).not_to be_active
      end
    end
  end

  it "accepts only 'Y' or 'N' for deepest" do
    expect{standard.deepest = "Hello"}.to raise_error(ArgumentError)
    %w[Y N].each do |new_val|
      expect{standard.deepest = new_val}.to change{standard.deepest}.to(new_val)
      if standard.deepest == 'Y'
        expect(standard).to be_deepest
      else
        expect(standard).not_to be_deepest
      end
    end
  end

  it "is instantiable from hash" do
    api_response["resources"].each do |resource|
      s = Standard.new(resource["data"])
      expect(s).not_to be_nil
      compare_obj_to_hash(s, resource["data"], poro_keys.dup.concat(ignore_keys))
      poro_keys.each { |key| expect(s).to respond_to(key) }
    end
  end

  it "sets parent_guid to nil when there is no parent in the hash" do
    hash = api_response["resources"].first["data"]
    hash.delete("parent")
    expect(hash).not_to have_key("parent")
    expect(Standard.new(hash).parent_guid).to be_nil
  end

  it "properly sets the parent_guid" do
    parent_guid = SecureRandom.uuid
    hash = api_response["resources"].first
    expect(Standard.new(hash).parent_guid).not_to be_nil
    hash["data"]["parent"]["guid"] = parent_guid
    expect(Standard.new(hash).parent_guid).to eq(parent_guid)
  end

  context "children" do
    let (:parent) { Standard.new(api_response["resources"][0]) }
    let (:child1) { Standard.new(api_response["resources"][1]) }
    let (:child2) { Standard.new(api_response["resources"][2]) }

    it "can be added to the standard" do
      expect{
        parent.add_child(child1)
      }.to change{parent.children}.from([]).to([child1])
      expect{
        child1.add_child(child2)
      }.not_to change{parent.children.count}
      expect{
        parent.add_child(child2)
      }.to change{parent.children.count}.from(1).to(2)
      expect(parent.children).to match_array([child1, child2])
    end

    it "can be removed from the standard" do
      [child1, child2].each { |c| parent.add_child(c) }
      expect{
        parent.remove_child(child1)
      }.to change{parent.children}.from([child1, child2]).to([child2])
      expect{
        parent.remove_child(child1)
      }.not_to change{parent.children}
      expect{
        parent.remove_child(child2)
      }.to change{parent.children}.from([child2]).to([])
    end
  end
end
