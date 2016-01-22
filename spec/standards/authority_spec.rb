RSpec.describe Authority do
  include ObjectHelper

  let(:auth_hash) do
    {
      "code" => "CC",
      "descr" => "NGA Center/CCSSO",
      "guid" => "A83297F2-901A-11DF-A622-0C319DFF4B22"
    }
  end

  let(:a){ Authority.from_hash(auth_hash) }

  it "is instantiable with hash" do
    compare_obj_to_hash(a, auth_hash)
  end

  it "can have children" do
    standards = (1..5).map{ |i| Standard.new({ guid: i.to_s }) }
    expect{a.children = standards}.to change{a.children}.from([]).to(standards)
  end

  it "omits empty children properly" do
    expect(a.children).to be_empty
    expect(a.to_h["children"]).to be_nil
  end
end
