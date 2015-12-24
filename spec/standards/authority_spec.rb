RSpec.describe Authority do
  include ObjectHelper

  let(:auth_hash) do
    {
      "code" => "CC",
      "descr" => "NGA Center/CCSSO",
      "guid" => "A83297F2-901A-11DF-A622-0C319DFF4B22"
    }
  end

  it "is instantiable with hash" do
    h = Authority.from_hash(auth_hash)
    compare_obj_to_hash(h, auth_hash)
  end

  it "can have children" do
    standards = (1..5).map{ |i| Standard.new({ guid: i.to_s }) }
    h = Authority.from_hash(auth_hash)
    expect{h.children = standards}.to change{h.children}.from([]).to(standards)
  end
end
