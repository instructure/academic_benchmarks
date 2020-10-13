RSpec.describe Document do
  include ObjectHelper

  let(:hash) do
    {
      "publication" => {
        "guid" => "964E0FEE-AD71-11DE-9BF2-C9169DFF4B22",
        "descr" => "Common Core State Standards"
      },
      "adopt_year" => 2000
    }
  end

  it "is instantiable with hash" do
    h = Document.from_hash(hash)
    compare_obj_to_hash(h, hash, ["publication"])
    expect(h.publication.is_a?(Publication)).to eq true
  end
end
