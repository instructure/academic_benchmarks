RSpec.describe StandardsTree do

  let(:ab) { ApiHelper::Live.new_handle }

  let(:valid_authority) do
    retval = ab.standards.authorities.first
    expect(retval).to be_a(Authority)
    retval
  end

  let(:stree) do
    sf = StandardsForest.new(ab.standards.search(authority: valid_authority.code))
    sf.consolidate_under_root(valid_authority)
  end

  context "pruning obesolete branches", vcr: {cassette_name: "standards_tree_pruning_obsolete_branches"} do
    let(:parent) { stree.children.first }

    it "correctly" do
      parent.children.first.status = "Obsolete"
      orig_num_children = parent.children.count
      expect{
        StandardsTree.new(stree.root, include_obsoletes: false)
      }.to change{ parent.children.count }.from(orig_num_children).to(orig_num_children - 1)
    end

    it "doesn't prune when it shouldn't" do
      parent.children.first.status = "Obsolete"
      expect{
        StandardsTree.new(stree.root, include_obsoletes: true)
      }.not_to change{ parent.children.count }
    end
  end
end
